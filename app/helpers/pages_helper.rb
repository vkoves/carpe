module PagesHelper
  # Returns a hash of { date => num }. Puts chart data on a fixed axis to
  # prevent weird scaling by filling in empty dates with a count of 0.
  def daily_date_data(date_count_data, date_range)
    Hash[date_range.map { |date| [date, 0] }].merge(date_count_data)
  end
end
