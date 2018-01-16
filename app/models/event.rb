require 'utilities'

#An event describes a schedule item, that is a single item occuring on a person's schedule
class Event < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :category
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
    all_repeat_exceptions.any? { |brk| datetime.between? brk.start, brk.end }
  end

  # Returns how long the event goes on for in seconds
  def duration
    end_date - date
  end

  # Returns true if this event can occur at the given time, false otherwise.
  def can_occur_on?(day)
    return false if on_break? day
    return true unless repeats?
    return false if repeat_start.present? and day < repeat_start
    return false if repeat_end.present? and day > repeat_end

    true
  end

  # Returns an array of events on every day that this event applies to between the given
  # /start/ and /end/ times.
  def events_in_range(start, finish, time_zone="UTC")
    event_days = dates_in_range_with_repeat(start, finish, time_zone)
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

  ##########################
  ##### HELPER METHODS #####
  ##########################

  private

  def repeat_clone(date)
    new_event = self.dup
    new_event.attributes = { date: date, end_date: date + duration }
    new_event
  end

  # Returns the first date this event will repeat for a given
  # /start/ time, /finish/ time, and repeat duration (i.e. /step/size).
  # If this event does not repeat during the given time, /finish/ will be returned instead.
  def first_repeat(start, finish, step)
    duration = (start.to_time - date.to_time).abs

    if start >= date
      first_repeat_date = date + (duration / step).ceil * step
    else
      first_repeat_date = date - (duration / step).floor * step
    end

    first_repeat_date.between?(start, finish) ? first_repeat_date : finish
  end

  # Returns an array of dates that this event object may apply to between
  # the given /start/ and /finish/ times.
  def dates_in_range_with_repeat(start, finish, time_zone="UTC")
    start = start.in_time_zone(time_zone)

    case repeat
    when 'daily'   then range start, finish, 1.day
    when 'weekly'  then range first_repeat(start, finish, 1.week), finish, 1.week
    when 'monthly' then range first_repeat(start, finish, 1.month), finish, 1.month
    when 'yearly'  then range first_repeat(start, finish, 1.year), finish, 1.year
    when /custom/
      _, repeat_every, repeat_unit = repeat.split("-")
      step = repeat_every.to_i.send(repeat_unit)
      range first_repeat(start, finish, step), finish, step
    when /certain_days/
      weekdays = repeat.split('-')[1].split(',').map(&:to_i)
      range(start, finish, 1.day).select { |day| weekdays.include?(day.wday) }
    else
      date.between?(start, finish) ? [date] : [] # this event doesn't repeat
    end
  end
end