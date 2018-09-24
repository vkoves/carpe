# Contains methods that aren't specific to any model, view, or controller, and
# deserve to be in the global namespace. As long as these global methods are
# wrapped in a module, the compiler shouldn't have any trouble tracing
# namespace collisions back to this file.

module Utilities
  # contains pluralize method
  include ActionView::Helpers::TextHelper

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

  # rubocop: disable MethodLength, AbcSize, CyclomaticComplexity

  # Returns a formattable string representing the distance between the current
  # time and the given time. For example, "3 minutes ago (5:50 PM)".
  def relative_time(to_time)
    duration = to_time - Time.current # it's in seconds
    secs, mins, days, months = duration_parts(duration)
    time = "%-l:%M %p" # time format

    case duration
    when -INFINITY..-1.month   then "#{pluralize months, 'month'} ago"
    when -1.month..-1.week     then "#{pluralize days, 'day'} ago"
    when -1.week..-2.days      then "last %A at #{time}"
    when -2.days..-1.day       then "yesterday at #{time}"
    when -1.day..-1.hour       then time
    when -1.hour..-1.minute    then "#{pluralize mins, 'minute'} ago (#{time})"
    when -1.minute...0.seconds then "#{pluralize secs, 'second'} ago (#{time})"
    when 0.seconds             then "right now"
    when 0.seconds...1.minute  then "#{pluralize secs, 'second'} from now (#{time})"
    when 1.minute...1.hour     then "#{pluralize mins, 'minute'} from now (#{time})"
    when 1.hour...1.day        then time
    when 1.day...2.days        then "tomorrow at #{time}"
    when 2.days...1.week       then "%A at #{time}"
    when 1.week...1.month      then "#{pluralize days, 'day'} from now"
    when 1.month...INFINITY    then "#{pluralize months, 'month'} from now"
    else raise "Congratulations, you won a bug!"
    end
  end

  # rubocop: enable MethodLength, AbcSize, CyclomaticComplexity
end

# Automatically include this modules methods in the global namespace.
include Utilities
