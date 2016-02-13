class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  
  def events_in_range(start_datetime, end_datetime) #returns the repeat copies of the event
     arr = []
     if repeat
      dates = (start_datetime...end_datetime).to_a #create an array of all dates in the range
       
      if repeat == "daily" #use all dates
        #do nothing!     
      elsif repeat == "weekly"
        dates = dates.select{|i| i.wday == date.wday}
      elsif repeat == "monthly"
        dates = dates.select{|i| i.mday == date.mday}
      elsif repeat == "yearly"
        dates = dates.select{|i| i.yday == date.yday}
      end
      
      dates.each do |date| #go through all the dates
        newEvent = self.dup #duplicate the base element without creating a database clone
        newEvent.date = self.date.change(day: date.day, month: date.month, year: date.year) #and determine the new start date
        newEvent.end_date = newEvent.date + (self.end_date - self.date) #determine proper end datetime by adding event duration to the proper start
        arr.append(newEvent) #append to output array
      end
     else
      arr.append(self)
     end
     return arr
  end
end
