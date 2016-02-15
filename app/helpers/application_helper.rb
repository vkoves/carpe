module ApplicationHelper
  def relative_time_ago (datetime)
    datetime = datetime.utc.localtime
    now = Time.now.localtime
    tomorrow = Time.now.tomorrow.localtime
    yesterday = Time.now.yesterday.localtime
    
    if(datetime.to_date == now.to_date) #It's today!
      hours_diff = ((datetime - now)/1.hour).round;
      minutes_diff = ((datetime - now)/1.minute).round;
        
      if(minutes_diff.abs < 60) #we need minutes
        if(minutes_diff > 0) #future
          return minutes_diff.to_s + " minutes from now"
        else
          return minutes_diff.abs.to_s + " minutes ago"
        end 
      end
      
      if(hours_diff > 0) #in the future
        if(hours_diff < 5) #less than five hours away
          return  hours_diff.to_s + " hours from now"
        else
          return datetime.strftime("today at %l:%M %p")
        end
      else #in the past
        if(hours_diff.abs < 5) #less than five hours away
          return  hours_diff.abs.to_s + " hours ago"
        else
          return datetime.strftime("today at %l:%M %p")
        end
      end
    elsif(datetime.to_date == tomorrow.to_date) #It's tomorrow
      return datetime.strftime("tomorrow at %l:%M %p")
    elsif(datetime.to_date == yesterday.to_date) #It's yesterday
      return datetime.strftime("yesterday at %l:%M %p")
    else
      days_diff = ((datetime - now)/1.day).round;
      if(days_diff > 0) #in the future
        if(days_diff < 7) #in the next week
          return datetime.strftime("on %A at %l:%M %p")
        else
          return days_diff.to_s + " days from now"
        end
      else #in the past
        if(days_diff.abs < 7) #in the past week
          return datetime.strftime("last %A at %l:%M %p")
        else
          return days_diff.abs.to_s + " days ago"
        end
      end
    end
  end
  
  #For getting times about an event
  def relative_event_time(event)
    
    #Start by figuring out the proper tense of the language
    if(event.date.past?)
      start_string = "Started "
    else
      start_string = "Starting "
    end
    if(event.end_date.past?)
      end_string = ", ended "
    else
      end_string = ", ending "
    end
    
    #Then just return relative 
    return start_string + relative_time_ago(event.date) + end_string + relative_time_ago(event.end_date)
  end
end
