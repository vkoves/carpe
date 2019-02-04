require "utilities"

# An event describes a schedule item, that is a single item occuring on a person's schedule
#
# There are a couple of different types of events to consider:
#
# 1) Repeating or Non-Repeating
# 2) User or Group
# 3) Host, Hosted, or Non-Hosted
#
# Explanation:
#
# 1) Rather than copying the same event onto multiple dates, Repeating events utilize
#    a `repeat` database column and to indicate which dates an event should occur on.
#    Non-Repeating only occur once between `date` and `end_date`.
#
# 2) Events have ownership. User events belong to `user` and do not have a
#    `group`. This kind of event belongs to `user` who is both the event's
#    creator and owner. Group events belong to `group` and are modifiable by
#    anybody in who has permission to do so. In this case, `user` represents
#    the event's creator, but not its owner.
#
# 3) Events can be shared between users. A Host event is an event that other
#    users have been invited to. When a user is invited, a duplicate of the
#    host event is created on the invited user's schedule. That newly created
#    event is called a Hosted event. Hosted events are kept in sync with their
#    parent host event - which is identified by the `base_event` column.
#
class Event < ApplicationRecord
  include Utilities

  # These are the attributes that should be updated on hosted events
  # when their host/base event is modified.
  SYNCED_EVENT_ATTRIBUTES = %w[
    name
    description
    date
    end_date
    repeat
    location
    repeat_start
    repeat_end
    guests_can_invite
    guest_list_hidden
  ].freeze

  enum privacy: {
    public_event: 0,
    private_event: 1
  }

  belongs_to :user
  alias_attribute :creator, :user

  belongs_to :group, optional: true
  belongs_to :category
  has_and_belongs_to_many :repeat_exceptions

  # Host Event
  has_many :event_invites, foreign_key: "host_event_id", dependent: :destroy
  has_many :invited_users, through: :event_invites, source: :user
  has_many :hosted_events, class_name: "Event", foreign_key: :base_event_id,
                           dependent: :destroy

  # Hosted Event
  has_one :host_event, class_name: "Event", foreign_key: :base_event_id,
                       dependent: :destroy

  has_one :event_invite, foreign_key: "hosted_event_id",
                         dependent: :destroy

  # Notify guests on update if there are invited users
  after_validation :notify_guests, on: :update, if: :has_guests?
  after_commit :update_hosted_events, on: :update, if: :host_event?

  # returns the event name, or an italicized untitled
  def get_html_name
    name.present? ? ERB::Util.html_escape(name) : "<i>Untitled</i>"
  end

  # returns the event name as a plain string
  def get_name
    name.empty? ? "Untitled" : name
  end

  # Returns true if this event is a repeating event, false otherwise.
  def repeats?
    repeat.present? && (repeat != "none")
  end

  # Returns true if this event is on break at the given time, false otherwise.
  def on_break?(datetime)
    all_repeat_exceptions.any? { |brk| datetime.to_date.between? brk.start, brk.end }
  end

  # Returns how long this event goes on for in seconds
  def duration
    end_date - date
  end

  # Returns an array of copies of this event on every day that this event applies
  # to between the given start time and end time. In addition a ActiveSupport::TimeZone
  # may be specified if daylight savings needs to be taken into account.
  def events_in_range(start_time, end_time, time_zone = "UTC")
    event_days = dates_in_range_with_repeat(start_time, end_time, time_zone)
    event_days.select { |day| can_occur_on? day }.map { |day| repeat_clone day }
  end

  # returns all repeat_exceptions that apply to this event, a combination of event and category level ones
  def all_repeat_exceptions
    repeat_exceptions + category.repeat_exceptions
  end

  # returns whether the event is currently going on
  def current?
    if date.past? && end_date.future? # if it started some time ago and ends some time from now
      true # then this is indeed current
    else # otherwise
      false # it is not
    end
  end

  def accessible_by?(user)
    category.accessible_by?(user)
  end

  # returns the event with details hidden
  def private_version
    private_event = dup
    private_event.name = "Private"
    private_event.description = ""
    private_event.location = ""
    private_event
  end

  def owner
    group || creator
  end

  def hosted_event?
    base_event_id.present? && !host_event?
  end

  def host_event?
    EventInvite.exists?(host_event: self)
  end

  def make_host_event!
    # owners of a hosted event are explicitly invited to their own event.
    EventInvite.create(user: creator, host_event: self, role: :host)
  end

  # Returns true if users have been invited to this event
  def has_guests?
    invited_users.count.positive?
  end

  ##########################
  ##### HELPER METHODS #####
  ##########################

  private

  # Returns true if this event can occur at the given time, false otherwise.
  def can_occur_on?(day)
    return false if on_break? day

    # what days a repeating event can occur on can be optionally limited
    if repeats?
      return false if repeat_start && (day < repeat_start)
      return false if repeat_end && (day > repeat_end)
    end

    true
  end

  # Returns a copy of the this event with a new starting time.
  def repeat_clone(start_time)
    new_event = dup
    new_event.attributes = { date: start_time, end_date: start_time + duration }
    new_event
  end

  # Returns the first date this event will repeat on for a given
  # range of time and repeat duration. If this event does not
  # repeat during the given time, nil is returned instead.
  def first_repeat(start_time, end_time, time_zone)
    origin = date.in_time_zone(time_zone)
    step = repeat_interval
    offset = (start_time.to_time - date.to_time).abs

    first_repeat_date = if start_time >= date
                          origin + (offset / step).ceil * step
                        else
                          origin - (offset / step).floor * step
                        end

    return first_repeat_date if first_repeat_date.between?(start_time, end_time)
  end

  # Returns an ActiveRecord::Duration indicating the fixed interval at which
  # this event repeats. If this event does not repeat or does not repeat
  # on a fixed interval, nil is returned instead.
  def repeat_interval
    case repeat
    when "daily" then 1.day
    when "weekly" then 1.week
    when "monthly" then 1.month
    when "yearly" then 1.year
    when /custom/ then
      _, repeat_num, repeat_unit = repeat.split("-")
      repeat_num.to_i.send(repeat_unit) # e.g. 1.day, 5.weeks
    end
  end

  def repeats_on_fixed_interval?
    repeat_interval != nil
  end

  def dates_in_range_fixed_timestep(start_time, end_time, time_zone)
    first_time = first_repeat(start_time, end_time, time_zone) || end_time
    range first_time, end_time, repeat_interval
  end

  # Works by generating an array of days this event may take place on and then
  # filtering out ones with the correct day of the week.
  def dates_in_range_certain_weekdays(start_time, end_time, time_zone)
    # time zone takes into account DST so it's relative to the original event date
    first_time = date.in_time_zone(time_zone).change(year: start_time.year,
                                                     month: start_time.month,
                                                     day: start_time.day)
    dates = range(first_time, end_time, 1.day)

    # e.g. "certain_days-0,1,2,6" / 0-6 represent weekdays - sunday being 0
    weekdays = repeat.split("-")[1].split(",").map(&:to_i)
    dates.select { |day| weekdays.include?(day.wday) }
  end

  # Returns an array of times that this event object may apply to between
  # the given start time and end time.
  def dates_in_range_with_repeat(start_time, end_time, time_zone)
    if repeats_on_fixed_interval?
      dates_in_range_fixed_timestep(start_time, end_time, time_zone)
    elsif repeat.include? "certain_days"
      dates_in_range_certain_weekdays(start_time, end_time, time_zone)
    else # this event doesn't repeat
      date.between?(start_time, end_time) ? [date] : []
    end
  end

  # Called when an update is correctly updated. Notifies all users invited to
  # this event, and the event owner EXCEPT the current_user (since they know
  # the event changed)
  def notify_guests
    # Note: If this is a hosted event (non-orig), the creator is an invited_user
    notify_targets = invited_users

    # If we know who changed the event, ensure they are not notified
    notify_targets -= [Current.user] if Current.user

    # Send an event_update_email to all notify targets
    notify_targets.each do |recipient|
      UserNotifier.event_update_email(recipient, self, changes).deliver_later
      Notification.send_event_update(recipient, self)
    end
  end

  # Copies the relevant event attributes from a host event to all of
  # its child events. This is done whenever a host event is updated.
  def update_hosted_events
    host_event_attrs = attributes.slice(*SYNCED_EVENT_ATTRIBUTES)
    hosted_events.update_all(host_event_attrs)
  end
end
