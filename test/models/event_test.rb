# To run this test, in the project directory run the command:
# bundle exec rake test test/models/event_test.rb

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "repeat start and end shouldn't impact original event if repeat type is none" do
  	start_date_time = DateTime.parse("2015-12-14 00:00:00")
  	end_date_time = DateTime.parse("2015-12-17 00:00:00")
  	repeat_dates = events(:repeat_none_with_start_and_end).events_in_range(start_date_time, end_date_time)
  	assert repeat_dates.length == 1, "Repeat dates length was supposed to be 1, was " + repeat_dates.length.to_s
  end
end
