# Contains methods that aren't specific to any model, view, or controller, and
# deserve to be in the global namespace. As long as these global methods are
# wrapped in a module, the compiler shouldn't have any trouble tracing
# namespace collisions back to this file.

module TextHelper
  extend ActionView::Helpers::TextHelper
end

module Utilities
  # just a nicer alias
  INFINITY = Float::INFINITY

  # Returns an enumerator of values beginning at /start/ going up to /finish/
  # based on the given /step/ size.
  #
  # For example, range(1, 5, 2).to_a = [1, 3]
  # The most common use case for this method is as an alternative to the
  # Date.Step(Date, step) method which uses a fixed step-size.
  #
  # Whereas range(DateTime.new(2013, 1, 1), DateTime.new(2014, 1, 1), 1.month)
  # properly returns the first day of each month rather than using a fixed 30 days.
  def range(start, finish, step)
    return [] if start >= finish

    Enumerator.new do |y|
      y << start
      while (start += step) < finish
        y << start
      end
    end
  end

  # Returns an array of units from ActiveSupport::Duration.
  # Amazingly, ActiveRecord::Duration doesn't already provide this.
  def duration_parts(duration)
    dur = duration.abs

    secs = dur.round
    mins = (dur / 1.minute).round
    days = (dur / 1.day).round
    months = (dur / 1.month).round

    [secs, mins, days, months]
  end

  # Returns a formattable string representing the distance between the current
  # time and the given time. For example, "3 minutes ago (5:50 PM)".
  #
  # This method has many different, customizable outputs that can't be avoided
  # So, it's coded as a flat, dumb lookup table.
  def relative_time(to_time) # rubocop:disable MethodLength, AbcSize, CyclomaticComplexity
    duration = to_time - Time.current # it's in seconds
    secs, mins, days, months = duration_parts(duration)
    time = "%-l:%M %p" # time format

    # special cases based on dates
    return "yesterday at #{time}" if to_time.to_date == Date.yesterday
    return "tomorrow at #{time}" if to_time.to_date == Date.tomorrow

    # all other wordings are based on duration
    case duration
    when -INFINITY..-1.month   then "#{plural months, 'month'} ago"
    when -1.month..-1.week     then "#{plural days, 'day'} ago"
    when -1.week..-1.day       then "last %A at #{time}"
    when -1.day..-1.hour       then time
    when -1.hour..-1.minute    then "#{plural mins, 'minute'} ago (#{time})"
    when -1.minute...0.seconds then "#{plural secs, 'second'} ago (#{time})"
    when 0.seconds             then "right now"
    when 0.seconds...1.minute  then "#{plural secs, 'second'} from now (#{time})"
    when 1.minute...1.hour     then "#{plural mins, 'minute'} from now (#{time})"
    when 1.hour...1.day        then time
    when 1.day...1.week        then "%A at #{time}"
    when 1.week...1.month      then "#{plural days, 'day'} from now"
    when 1.month...INFINITY    then "#{plural months, 'month'} from now"
    else raise "Congratulations, you won a bug!"
    end
  end

  private

  # Alias for pluralize. This allows it to be used outside of views.
  def plural(*args)
    TextHelper.pluralize(*args)
  end
end
