# To run this test, in the project directory run the command:
# bundle exec rake test test/models/event_test.rb

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "repeat start and end shouldn't impact original event if repeat type is none" do
  	event = events(:repeat_none_with_start_and_end)
  	start_date_time = (event.date - 2.day).to_datetime
  	end_date_time = (event.end_date + 2.day).to_datetime
  	repeat_events = event.events_in_range(start_date_time, end_date_time)
  	assert repeat_events.length == 1, "Repeat dates length was supposed to be 1, was " + repeat_events.length.to_s
  end

  test "repeat daily should happen once a day" do
  	event = events(:repeat_daily)
  	#Create a 4 day date range
  	start_date_time = (event.date - 2.day).to_datetime
  	end_date_time = (event.end_date + 2.day).to_datetime
  	#Get all the repeat instances
  	repeat_events = event.events_in_range(start_date_time, end_date_time)
  	#And make sure there were 4 of them, since this repeats daily
  	assert repeat_events.length == 4, "Repeat dates length was supposed to be 4, was " + repeat_events.length.to_s
  end

  test "repeat clones should have proper date" do
    event = events(:repeat_daily)
    #Create a 4 day date range
    start_date_time = (event.date - 2.day).to_datetime
    end_date_time = (event.end_date + 2.day).to_datetime
    repeat_dates = (start_date_time ... end_date_time).to_a #create a range of dates and convert to array
    repeat_dates = repeat_dates.map{|d| d.to_date} #convert to date from date_time

    #Get all the repeat instances
    repeat_events = event.events_in_range(start_date_time, end_date_time)
    #Then get the dates the repeat instances fall on
    repeat_events_dates =  repeat_events.map{|r| r.date.to_date}

    #Then test that the repeat instance dates are the same as the range of dates, since this event repeats daily
    assert repeat_dates - repeat_events_dates == [], "The repeat clones dates were supposed to line up with the date range." + 
    "\nRepeat clones dates were instead \n" + repeat_events_dates.to_s +
    "\nWhile the date range was \n" + repeat_dates.to_s
  end
end
