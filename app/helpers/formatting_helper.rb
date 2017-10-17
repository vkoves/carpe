# Typically, when displaying information in views, it is beneficial to
# display things in a consistent format and include a default value
# for missing values. However, doing so results in a lot of redundant code.
# Thus, this module contains view helpers to cut down on that code duplication
# and move any complex formatting away from both controllers and views.

module FormattingHelper
  def format_time(time, format = :long_ordinal, default = "not available")
    time&.to_s(format) or default
  end
end
