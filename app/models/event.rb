#An event describes a schedule item, that is a single item occuring on a person's schedule
class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :category
  has_and_belongs_to_many :repeat_exceptions

  def get_html_name #returns the event name, or an italicized untitled
    name.empty? ? "<i>Untitled</i>" : name
  end

  def get_name #returns the event name as a plain string
    name.empty? ? "Untitled" : name
  end

  # Returns whether this event is on break on the given date.
  def on_break?(datetime)
    all_repeat_exceptions.any? { |brk| datetime.between? brk.start, brk.end }
  end

  # Returns copies of the event on every day it applies to between /start/ and /end/.
  def events_in_range(start_datetime, end_datetime)
    return [self] if repeat.blank? or repeat == 'none' # just use the existing event

    events_array = [] # an output array for cloned events

    # get all candidate dates for the event (ignores exceptions and repeat date range)
    candidate_dates = dates_in_range_with_repeat start_datetime, end_datetime

    # now only take events in repeat_start..repeat_end that are not on break
    candidate_dates.each do |day|
      next if repeat_start.present? and not day.between? repeat_start, repeat_end
      next if on_break?(day)

      events_array.append(repeat_clone(day))
    end

    events_array
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
    private_event.name = "<i>Private</i>"
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

  # Similar to Date.step(Date, step), except it actually works with months and years.
  # For example, range DateTime.new(2013,01,01), DateTime.new(2014,01,01), 1.month
  # properly returns the first day of each month rather than using a fixed 30 days.
  def range(start, finish, step)
    return [] if start.nil? or finish.nil?

    Enumerator.new do |y|
      y << start
      while (start += step) <= finish
        y << start
      end
    end
  end

  def select_custom_repeat_dates(start_date, end_date)
    repeat_data = repeat.split("-")
    repeat_num = repeat_data[1].to_i # repeat this event every n
    repeat_unit = repeat_data[2] # days/weeks/months/years
    first_weekday = (start_date..end_date).find { |day| (day.wday - date.wday) % repeat_num == 0}

    case repeat_unit
    when 'days'   then range first_weekday, end_date, repeat_num.days
    when 'weeks'  then range first_weekday, end_date, repeat_num.weeks
    when 'months' then range first_weekday, end_date, repeat_num.months
    when 'years'  then range first_weekday, end_date, repeat_num.years
    end
  end

  # Returns /dates/ after taking all the dates on certain weekdays.
  # `repeat` should look something along the lines of "certain_days-1,3,4,5"
  # 1 meaning monday, 2 tuesday, ..., 6 saturday, and 0 sunday.
  def select_certain_dates(dates)
    weekday_nums = repeat.split('-')[1].split(',').map(&:to_i)
    dates.select { |day| weekday_nums.include?(day.wday) }
  end

  # Takes a DateTime /start_date/ and a DateTime /end_date/ and returns
  # a collection of dates in this range that the current event object applies to.
  def dates_in_range_with_repeat(start_date, end_date)
    first_weekday = (start_date..end_date).find { |day| day.wday == date.wday }

    case repeat
    when 'daily'        then start_date..end_date # this event repeats every day
    when 'weekly'       then range first_weekday, end_date, 1.week
    when 'monthly'      then range first_weekday, end_date, 1.month
    when 'yearly'       then range first_weekday, end_date, 1.year
    when /certain_days/ then select_certain_dates start_date..end_date
    when /custom/       then select_custom_repeat_dates start_date, end_date
    else [date] # this event doesn't repeat
    end
  end
end
