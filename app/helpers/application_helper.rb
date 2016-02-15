module ApplicationHelper
  def relative_time_ago (datetime)
    datetime = datetime.localtime
    now = Time.now.localtime
    tomorrow = Time.now.tomorrow.localtime
    yesterday = Time.now.yesterday.localtime
    
    if(datetime.to_date == now.to_date) #It's today!
      hours_diff = ((datetime - now)/1.hour).round;
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
end
