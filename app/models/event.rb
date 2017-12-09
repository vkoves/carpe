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

  # Returns true if this event is currently on break at the given time, false otherwise.
  def on_break?(datetime)
    all_repeat_exceptions.any? { |brk| datetime.between? brk.start, brk.end }
  end

  # Returns true if this event is currently repeating at the given time, false otherwise.
  def repeating?(datetime)
    return false if repeat_start.present? and datetime < repeat_start
    return false if repeat_end.present? and datetime > repeat_end
    return false if on_break? datetime

    true
  end

  # Returns copies of the event on every day it applies to between /start/ and /end/.
  def events_in_range(start_datetime, end_datetime)
    unless repeats?
      # just return the current event, as it's the only relevant one.
      return date.between?(start_datetime, end_datetime) ? [self] : []
    end

    # get all candidate dates for the event (ignores exceptions and repeat date range)
    candidate_dates = dates_in_range_with_repeat start_datetime, end_datetime

    # now only take candidates actually in this event's repeat range that aren't on break.
    candidate_dates.map { |day| repeat_clone day if repeating? day }.compact
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
    self_date = self.date
    self_dst = self_date.utc.in_time_zone("Central Time (US & Canada)").dst? #get whether this event is in daylight savings time
    now_dst = Time.now.utc.in_time_zone("Central Time (US & Canada)").dst? #get whether the current time is in daylight savings
    one_hour = 1.hour

    new_event = self.dup #duplicate the base element without creating a database clone
    new_start_date = self_date.change(day: date.day, month: date.month, year: date.year) #and determine the new start date
    new_end_date = new_start_date + (self.end_date - self_date) #determine proper end datetime by adding event duration to the proper start

    if self_dst != now_dst #if the date is in daylight savings, but we are not, or vice versa
      if self_dst
        new_event.date = new_start_date + one_hour
        new_event.end_date = new_end_date + one_hour
      else
        new_event.date = new_start_date - one_hour
        new_event.end_date = new_end_date - one_hour
      end
    else
      new_event.date = new_start_date
      new_event.end_date = new_end_date
    end

    return new_event
  end

  # Returns an enumerator of all the dates between /start_date/ and /end_date/
  # that this custom repeating event will occur on. This is a helper method for
  # dates_in_range_with_repeat.
  #
  # For example, if an event occurs on 7/11/17 and repeats every 3 days - and
  # we want all the dates this applies to between 7/04/17 - 7/15/17. Then this
  # method will return (7/5, 7/8, 7/11, 7/14). It does so by finding the
  # day that the repeating event will occur on in the specified range
  # and stepping through dates until it has reached the given 'end date'.
  def select_custom_repeat_dates(start_date, end_date)
    repeat_data = repeat.split("-")
    repeat_num = repeat_data[1].to_i # repeat this event every n
    repeat_unit = repeat_data[2] # days/weeks/months/years

    dates = range(start_date, end_date, 1.day)
    first_weekday = dates.find { |day| (day.wday - date.wday) % repeat_num == 0 }

    case repeat_unit
    when 'days'   then range first_weekday, end_date, repeat_num.days
    when 'weeks'  then range first_weekday, end_date, repeat_num.weeks
    when 'months' then range first_weekday, end_date, repeat_num.months
    when 'years'  then range first_weekday, end_date, repeat_num.years
    end
  end

  # Returns an array of dates from taking only certain weekdays from the array
  # of /dates/. 'repeat' should look something along the lines of "certain_days-1,3,4,5".
  # 1 meaning monday, 2 tuesday, ..., 6 saturday, and 0 sunday.
  # This is a helper method for dates_in_range_with_repeat.
  def select_certain_dates(dates)
    weekday_nums = repeat.split('-')[1].split(',').map(&:to_i)
    dates.select { |day| weekday_nums.include?(day.wday) }
  end

  # Similar to select_custom_repeat_dates, except the repeat dates are predefined.
  # This is a helper method for dates_in_range_with_repeat.
  def select_repeat_dates(start_date, end_date, step)
    dates = range(start_date, end_date, 1.day)
    first_weekday = dates.find { |day| day.wday == date.wday }
    range first_weekday, end_date, step
  end

  # Takes a DateTime /start_date/ and a DateTime /end_date/ and returns
  # a collection of dates in this range that the current event object applies to.
  def dates_in_range_with_repeat(start_date, end_date)
    case repeat
    when 'daily'        then range start_date, end_date, 1.day
    when 'weekly'       then select_repeat_dates start_date, end_date, 1.week
    when 'monthly'      then select_repeat_dates start_date, end_date, 1.month
    when 'yearly'       then select_repeat_dates start_date, end_date, 1.year
    when /certain_days/ then select_certain_dates range(start_date, end_date, 1.day)
    when /custom/       then select_custom_repeat_dates start_date, end_date
    else [date] # this event doesn't repeat
    end
  end
end
