# Contains methods that aren't specific to any model, view, or controller, and
# deserve to be in the global namespace. As long as these global methods are
# wrapped in a module, the compiler shouldn't have any trouble tracing
# namespace collisions back to this file.

module Utilities

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
end

# Automatically include this modules methods in the global namespace.
include Utilities
