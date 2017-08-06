#An event describes a schedule item, that is a single item occuring on a person's schedule
class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  belongs_to :category

  has_many :users_events, :class_name => 'UsersEvent'
  has_many :invited_users, :through => :users_events, :source => 'receiver'

  has_and_belongs_to_many :repeat_exceptions

  def get_html_name #returns the event name, or an italicized untitled
    name.empty? ? "<i>Untitled</i>" : name
  end

  def get_name #returns the event name as a plain string
    name.empty? ? "Untitled" : name
  end

  def events_in_range(start_datetime, end_datetime) #returns the repeat copies of the event
     events_array = [] #define the array we will return with all the event "clones"

     if repeat and !(repeat.empty? or repeat == "none")
      dates = (start_datetime...end_datetime).to_a #create an array of all dates in the range

      dates = dates_in_range_with_repeat(dates)

      dates.each do |date| #go through all the dates
        #if this date is before the event's start repeat
        if (repeat_start and date < repeat_start) or (repeat_end and date > repeat_end) #or after it's end repeat
          next #skip this date
        end

        #Now check if this event falls onto one of it's specified breaks
        on_break = false
        start_date = date.to_date

        self.all_repeat_exceptions.each do |brk|
          if brk.start <= start_date and brk.end >= start_date
            on_break = true
            break
          end
        end

        next if on_break #continue to the next event if this one is on break

        new_event = repeat_clone(date)

        events_array.append(new_event) #append to output array
      end
     else #if there is no repeat_type
      events_array.append(self) #just use the existing event
     end

     return events_array #and return
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

  #Returns the dates that are valid within a range given a certain repeat string
  def dates_in_range_with_repeat(dates)
      start_date = date.to_date #conver the start datetime to a real Date

      if repeat == "daily" #use all dates
        #do nothing!
      elsif repeat == "weekly"
        dates = dates.select{|curr_date_time| curr_date_time.wday == date.wday}
      elsif repeat == "monthly"
        dates = dates.select{|curr_date_time| curr_date_time.mday == date.mday}
      elsif repeat == "yearly"
        dates = dates.select{|curr_date_time| curr_date_time.yday == date.yday}
      elsif repeat.include? "custom" #it's a custom repeat
        repeat_data = repeat.split("-")
        repeat_num = repeat_data[1].to_i
          repeat_unit = repeat_data[2]

        dates = dates.select{|curr_date_time|
          curr_date = curr_date_time.to_date

          if repeat_unit == "days"
            (curr_date - start_date) % repeat_num == 0
          elsif repeat_unit == "weeks"
            ((curr_date - start_date)/7) % repeat_num == 0
          elsif repeat_unit == "months"
            ((curr_date_time.year - date.year)* 12 + curr_date_time.month -  date.month) % repeat_num == 0
          elsif repeat_unit == "years"
            curr_date_time.year - date.year % repeat_num == 0
          end
        }
      elsif repeat.include? "certain_days" #if it's a repeat certain days type
        #Get the array of day numbers (Ex: M-F repeat would be ["1","2","3","4", "5"])
        days_num_array = repeat.split("-")[1].split(",")
        dates = dates.select{|curr_date_time| days_num_array.include?(curr_date_time.wday.to_s)}
      else #this event doesn't repeat!
        dates = dates.select{|curr_date_time| curr_date_time.to_date == start_date}
      end

      return dates
  end
end
