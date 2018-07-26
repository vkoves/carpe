require 'overridden_helpers'

module ApplicationHelper
  include OverriddenHelpers

  def relative_time_ago (datetime, start_caps)
    time_format = "%l:%M %p" #anything today that's not an hour away, say this

    # Use home_time_zone if signed in
    current_user ? time_zone = current_user.home_time_zone : time_zone = "Central Time (US & Canada)"

    datetime = datetime.utc.in_time_zone(time_zone)
    now = Time.now.in_time_zone(time_zone)

    tomorrow = Time.now.tomorrow.in_time_zone(time_zone)
    yesterday = Time.now.yesterday.in_time_zone(time_zone)

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

  def link_to_block(name = nil, options = nil, html_options = nil)
    link_to(options, html_options) do
      content_tag :span, name
    end
  end

  # Adds :size parameter to html_options. This is the size of the image
  # being requested.
  def link_avatar(options, html_options = {})
    html_options.merge!(class: " round-avatar") { |_, old, new| old + new }
    url = options.avatar_url(html_options[:size] || 256)

    link_to options, html_options do
      image_tag url
    end
  end

  def validation_error_messages!(resource)
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      count: resource.errors.count,
                      resource: resource.class.model_name.human.downcase)

    html = <<-HTML
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
end
