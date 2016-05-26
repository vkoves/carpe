class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  has_and_belongs_to_many :repeat_exceptions

  def get_name(use_html) #get the name, returning untitled if there isn't one
    if name.empty?
      if use_html
        return "<i>Untitled</i>"
      else
        return "Untitled"
      end
    else
      return name
    end
  end

  def events_in_range(start_datetime, end_datetime) #returns the repeat copies of the event
     arr = []
     if repeat and !repeat.empty?
      dates = (start_datetime...end_datetime).to_a #create an array of all dates in the range

      if repeat == "daily" #use all dates
        #do nothing!
      elsif repeat == "weekly"
        dates = dates.select{|i| i.wday == date.wday}
      elsif repeat == "monthly"
        dates = dates.select{|i| i.mday == date.mday}
      elsif repeat == "yearly"
        dates = dates.select{|i| i.yday == date.yday}
      elsif repeat.include? "custom" #it's a custom repeat
        num = repeat.split("-")[1].to_i
          unit = repeat.split("-")[2]

        dates = dates.select{
          |i|
          if unit == "days"
            (i.to_date - date.to_date) % num == 0
          elsif unit == "weeks"
            ((i.to_date - date.to_date)/7) % num == 0
          elsif unit == "months"
            ((i.year - date.year)* 12 + i.month -  date.month) % num == 0
          elsif unit == "years"
            i.year - date.year % num == 0
          end
        }
      else #this event doesn't repeat!
        dates = dates.select{|i| i.to_date == date.to_date}
      end

      dates.each do |date| #go through all the dates
        if self.repeat_start and date < self.repeat_start #if this event has a start repeat, and this date is before it
          next #skip it
        end

        if self.repeat_end and date > self.repeat_end #similarly, if this date has an end repeat, and this date is after it
          next #skip it
        end

        #Now check if this event falls onto one of it's specified breaks
          onBreak = false
          self.repeat_exceptions.each do |brk|
            if brk.start <= date.to_date and brk.end >= date.to_date
              onBreak = true
              break
            end
          end
          self.category.repeat_exceptions.each do |brk|
            if brk.start <= date.to_date and brk.end >= date.to_date
              onBreak = true
              break
            end
          end

        next if onBreak #continue to the next event if this one is on break

        newEvent = self.dup #duplicate the base element without creating a database clone
        newEvent.date = self.date.change(day: date.day, month: date.month, year: date.year) #and determine the new start date
        newEvent.end_date = newEvent.date + (self.end_date - self.date) #determine proper end datetime by adding event duration to the proper start

        if self.date.utc.in_time_zone("Central Time (US & Canada)").dst? != Time.now.utc.in_time_zone("Central Time (US & Canada)").dst? #if the date is in daylight savings, but we are not, or vice versa
          if self.date.utc.in_time_zone("Central Time (US & Canada)").dst?
            newEvent.date = newEvent.date + 1.hour
            newEvent.end_date = newEvent.end_date + 1.hour
          else
            newEvent.date = newEvent.date - 1.hour
            newEvent.end_date = newEvent.end_date - 1.hour
          end
        end

        arr.append(newEvent) #append to output array
      end
     else
      arr.append(self)
     end
     return arr
  end

  #returns whether the event is currently going on
  def current?
    if self.date.past? and self.end_date.future? #if it started some time ago and ends some time from now
      return true #then this is indeed current
    else #otherwise
      return false #it is not
    end
  end
end
