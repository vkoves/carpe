module ApplicationHelper
  def relative_time_ago (datetime, start_caps)
    time_format = "%l:%M %p" #anything today that's not an hour away, say this
    
    datetime = datetime.utc.in_time_zone("Central Time (US & Canada)")
    now = Time.now.in_time_zone("Central Time (US & Canada)")

    tomorrow = Time.now.tomorrow.in_time_zone("Central Time (US & Canada)")
    yesterday = Time.now.yesterday.in_time_zone("Central Time (US & Canada)")

    if(datetime.to_date == now.to_date) #It's today!
      hours_diff = ((datetime - now)/1.hour).round
      minutes_diff = ((datetime - now)/1.minute).round

      if(minutes_diff.abs < 60) #we need to use minutes or seconds
        seconds_diff = ((datetime - now)/1.second).round

        if(seconds_diff.abs < 60) #we should use seconds
          if(seconds_diff >= 0) #future
            time_format = pluralize(seconds_diff, 'second') + " from now (" + time_format + ")"
          else
            time_format = pluralize(seconds_diff.abs, 'second') + " ago (" + time_format + ")"
          end
        end

        if(minutes_diff > 0) #in the future
          time_format = pluralize(minutes_diff, 'minute') + " from now (" + time_format + ")"
        else #in the past
          time_format = pluralize(minutes_diff.abs, 'minute') + " ago (" + time_format + ")"
        end
      end


      # if(hours_diff > 0) #in the future
      #   if(hours_diff < 5) #less than five hours away
      #     return  pluralize(hours_diff, 'hour') + " from now"
      #   else
      #     time_format = "today at %l:%M %p"
      #   end
      # else #in the past
      #   if(hours_diff.abs < 5) #less than five hours away
      #     return  pluralize(hours_diff.abs, 'hour') + " ago"
      #   else
      #     time_format = "today at %l:%M %p"
      #   end
      # end
    elsif(datetime.to_date == tomorrow.to_date) #It's tomorrow
      time_format = "tomorrow at " + time_format
    elsif(datetime.to_date == yesterday.to_date) #It's yesterday
      time_format = "yesterday at " + time_format
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
          time_format = "%A at " + time_format
        else
          return pluralize(days_diff, 'day') + " from now"
        end
      else #in the past
        if(days_diff.abs < 7) #in the past week
          time_format = "last %A at " + time_format
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
      end_string = ", ends "
    end

    #Then just return relative
    return raw start_string + relative_time_ago(event.date, false) + end_string + relative_time_ago(event.end_date, false)
  end

  #Takes a hash of datetimes to number and adds empty dates between the first and last value
  def date_chart_fix(date_count_hash, start_date, end_date)
    valid_dates_array = (start_date.to_date...end_date.to_date).to_a
    dates_hash = {}

    valid_dates_array.each{|date| dates_hash[date] = 0} #create an empty hash with all valid dates 

    date_count_hash.keys.each do |key| #then iterate through all dates in the original hash
      if dates_hash[key.to_date]
        dates_hash[key.to_date] += date_count_hash[key] #and add
      else
        dates_hash[key.to_date] = date_count_hash[key]
      end
    end

    return dates_hash  
  end

  # Gets the events to be displayed on the schedule partial depending on if @user and/or @group are defined
  def fetch_schedule_events(user_viewing, group_viewing)
    if user_viewing
      events = user_viewing.get_events(current_user)
    elsif group_viewing
      events = group_viewing.events
    end
  end

  # Gets the categories to be displayed on the schedule partial depending on if @user and/or @group are defined
  def fetch_schedule_categories(user_viewing, group_viewing)
    if user_viewing
      categories = user_viewing.get_categories(current_user)
    elsif group_viewing
      categories = group_viewing.categories
    end
  end

  # Get attributes for events, particularly pulling in break_ids
  def get_event_attributes(events)
    eventAttributes = []
    events.includes(:repeat_exceptions).each do |event|
      if @group or (@user and !event.group) # don't show group events on a user's schedule, even if they made it?
        atr = event.attributes
        atr[:break_ids] = event.repeat_exception_ids #.repeat_exceptions.pluck(:id)
        eventAttributes.push(atr)
      end
    end
    return eventAttributes
  end

  # Get attributes for categories, particularly pulling in break_ids
  def get_category_attributes(categories)
    categoryAttributes = []
    categories.includes(:repeat_exceptions).each do |category|
      atr = category.attributes
      atr[:break_ids] = category.repeat_exception_ids
      categoryAttributes.push(atr)
    end
    return categoryAttributes
  end 
end
