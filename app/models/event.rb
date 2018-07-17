require 'utilities'

#An event describes a schedule item, that is a single item occuring on a person's schedule
class Event < ApplicationRecord
  enum privacy: {
    public_event: "public",
    private_event: "private"
  }

  belongs_to :user
  alias_attribute :creator, :user

  belongs_to :group
  belongs_to :category

  has_many :event_invites, dependent: :destroy
  has_many :invited_users, through: :event_invites, source: :recipient

  has_and_belongs_to_many :repeat_exceptions

  def get_html_name #returns the event name, or an italicized untitled
    name.present? ? ERB::Util.html_escape(name) : "<i>Untitled</i>"
  end

  def get_name #returns the event name as a plain string
    name.empty? ? "Untitled" : name
  end

  # Returns true if this event is a repeating event, false otherwise.
  def repeats?
    repeat.present? and repeat != 'none'
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

  #returns all repeat_exceptions that apply to this event, a combination of event and category level ones
  def all_repeat_exceptions
    return repeat_exceptions + category.repeat_exceptions
  end

  #returns whether the event is currently going on
  def current?
    if self.date.past? and self.end_date.future? #if it started some time ago and ends some time from now
      return true #then this is indeed current
    else #otherwise
      return false #it is not
    end
  end

  def has_access?(user) #a wrapper for category has access
    return category.has_access?(user)
  end

  def private_version #returns the event with details hidden
    private_event = self.dup
    private_event.name = "Private"
    private_event.description = ""
    private_event.location = ""
    return private_event
  end

  # Returns true if this is a parent event that other events pull
  # data from (i.e. it uses the event invites feature).
  # If there are no outstanding invites this event won't be considered
  # a host event.
  def host_event?
    !invited_users.empty?
  end

  # Returns true if this event pulls data from a parent event.
  # Specifically, when this event was generated from an event invite.
  def hosted_event?
    base_event_id != nil
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
      return false if repeat_start and day < repeat_start
      return false if repeat_end and day > repeat_end
    end

    return true
  end

  # Returns a copy of the this event with a new starting time.
  def repeat_clone(start_time)
    new_event = self.dup
    new_event.attributes = { date: start_time, end_date: start_time + duration }
    return new_event
  end

  # Returns the first date this event will repeat on for a given
  # range of time and repeat duration. If this event does not
  # repeat during the given time, nil is returned instead.
  def first_repeat(start_time, end_time, time_zone)
    origin = date.in_time_zone(time_zone)
    step = repeat_interval
    offset = (start_time.to_time - date.to_time).abs

    if start_time >= date
      first_repeat_date = origin + (offset / step).ceil * step
    else
      first_repeat_date = origin - (offset / step).floor * step
    end

    return first_repeat_date if first_repeat_date.between?(start_time, end_time)
  end

  # Returns an ActiveRecord::Duration indicating the fixed interval at which
  # this event repeats. If this event does not repeat or does not repeat
  # on a fixed interval, nil is returned instead.
  def repeat_interval
    case repeat
    when 'daily' then 1.day
    when 'weekly' then 1.week
    when 'monthly' then 1.month
    when 'yearly' then 1.year
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
    weekdays = repeat.split('-')[1].split(',').map(&:to_i)
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
end