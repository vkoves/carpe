module ApplicationHelper
  def relative_time_ago (datetime, start_caps)
    datetime = datetime.utc.in_time_zone("Central Time (US & Canada)")
    now = Time.now.in_time_zone("Central Time (US & Canada)")

    tomorrow = Time.now.tomorrow.in_time_zone("Central Time (US & Canada)")
    yesterday = Time.now.yesterday.in_time_zone("Central Time (US & Canada)")

    if(datetime.to_date == now.to_date) #It's today!
      hours_diff = ((datetime - now)/1.hour).round;
      minutes_diff = ((datetime - now)/1.minute).round;

      if(minutes_diff.abs < 60) #we need to use minutes
        if(minutes_diff > 0) #in the future
          return pluralize(minutes_diff, 'minute') + " from now"
        else #in the past
          return pluralize(minutes_diff.abs, 'minute') + " ago"
        end
      end

      if(hours_diff > 0) #in the future
        if(hours_diff < 5) #less than five hours away
          return  pluralize(hours_diff, 'hour') + " from now"
        else
          time_format = "today at %l:%M %p"
        end
      else #in the past
        if(hours_diff.abs < 5) #less than five hours away
          return  pluralize(hours_diff.abs, 'hour') + " ago"
        else
          time_format = "today at %l:%M %p"
        end
      end
    elsif(datetime.to_date == tomorrow.to_date) #It's tomorrow
      time_format = "tomorrow at %l:%M %p"
    elsif(datetime.to_date == yesterday.to_date) #It's yesterday
      time_format = "yesterday at %l:%M %p"
    else #use days, months or years
      days_diff = ((datetime - now)/1.day).round
      if(days_diff.abs > 31) #use months as it's more than 31 days in the past or future
        months_diff = ((datetime - now)/1.month).round #get months
        if(months_diff < 0) #in the past
          return pluralize(months_diff.abs, 'month') + " ago"
        else
          return pluralize(months_diff, 'month') + " from now"
        end
      elsif(days_diff > 0) #in the future
        if(days_diff < 7) #in the next week
          time_format = "on %A at %l:%M %p"
        else
          return pluralize(days_diff, 'day') + " from now"
        end
      else #in the past
        if(days_diff.abs < 7) #in the past week
          time_format = "last %A at %l:%M %p"
        else
          return pluralize(days_diff.abs, 'day') + " ago"
        end
      end
    end

    if(start_caps) #if this needs capitalization to start
      time_format[0] = time_format[0,1].upcase #then capitalize the first char of the format
    end

    #if we haven't returned with a language based time, run formatting
    return local_time(datetime, time_format) #datetime.strftime("today at %l:%M %p")

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
    return raw start_string + relative_time_ago(event.date, false) + end_string + relative_time_ago(event.end_date, false)
  end
end
