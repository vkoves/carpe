# To run all tests, in the project directory run the command:
# bundle exec rake test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rake test test/controllers/event_test.rb

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @daily = events(:repeat_daily)
    @morning = @daily.date.to_datetime.at_beginning_of_day
  end

  test "repeat start and end shouldn't impact original event if repeat type is none" do
    event = events(:repeat_none_with_start_and_end)
    repeat_events = event.events_in_range event.date - 2.days, event.end_date + 2.days
    assert_equal 1, repeat_events.length
  end

  test "users should have access to their own events" do
    assert categories(:private).has_access?(users(:viktor)),
           "user does not have access to their own events (according to has_access?)"
  end

  test "private_version should return an event with its details hidden" do
    private_event = events(:simple).private_version
    assert_empty private_event.description, "event details were not hidden"
  end

  test "repeat clones should have proper date" do
    start_date = (@daily.date - 2.days).to_datetime
    end_date = (@daily.end_date + 2.days).to_datetime
    repeat_dates = (start_date...end_date).map(&:to_date)

    # get the dates the repeat instances fall on
    event_dates = @daily.events_in_range(start_date, end_date).map { |r| r.date.to_date }

    # since the event repeats daily, it should use all of the dates.
    assert_equal repeat_dates, event_dates
  end

  test "get_name will return either the event name or a placeholder" do
    assert_equal events(:simple).name, events(:simple).get_name,
                 "Named event did not return it's name"

    assert_not_empty events(:nameless_event).get_name,
                     "Nameless event should return some placeholder name"
  end

  test "get_html_name will return either the event name or an html placeholder" do
    assert_equal events(:simple).name, events(:simple).get_html_name,
                 "Named event did not return it's name"


    html_name = events(:nameless_event).get_html_name
    assert_not_empty html_name, "Nameless event should return some placeholder name"
    assert html_name.valid_html?, "Placeholder name must be valid html"
  end

  test "current? should return true for events that are happening right now" do
    event = events(:simple)

    event.date = 1.hour.ago
    event.end_date = 1.hour.from_now
    assert event.current?, "Current event was not considered current"

    event.date = 1.hour.from_now
    event.end_date = 2.hours.from_now
    assert_not event.current?, "Non-current event considered current"
  end

  test "events_in_range should ignore repeat events that have not started yet" do
    @daily.repeat_start = @morning + 1.day
    @daily.repeat_end = @morning + 3.days
    events = @daily.events_in_range(@morning, @morning + 4.days)

    assert_not_includes events, @daily
  end

  test "events_in_range should not include repeat events that are on break" do
    exception = repeat_exceptions(:one)

    exception.start = @morning
    exception.end = @morning.at_end_of_day + 2.days
    @daily.repeat_exceptions << exception

    events = @daily.events_in_range(@morning, @morning.at_end_of_day + 3.days)
    assert_equal 1, events.length, "repeated events that are on break not being excluded"
  end

  # TODO: make repeat_clone testable. also, "Central Time (US & Canada)"?
  test "repeat_clone takes daylight savings into account" do
    flunk "how should we test or refactor this code?"
  end

  test "events can be repeated daily, weekly, monthly, and yearly" do
    event = events(:repeat_daily)
    start = event.date.to_datetime
    event.end_date = start + 2.hours

    event.repeat = "daily"
    events = events(:repeat_daily).events_in_range start, start+ 4.days
    assert_equal 4, events.length, "daily event should only repeat 4 times in 4 days"

    events = events(:repeat_daily).events_in_range start, start + 4.days + 3.hours
    assert_equal 5, events.length, "daily event should only repeat 5 times in 4.25 days"

    event.repeat = "weekly"
    events = event.events_in_range start.to_date.at_beginning_of_month,
                                   start.to_date.at_end_of_month
    assert_equal 5, events.length,
                 "this weekly event should repeat 5 times in december of 2015"

    event.repeat = "monthly"
    events = event.events_in_range(start.at_beginning_of_year, start.at_end_of_year)
    assert_equal 12, events.length, "monthly event should only repeat 12 times in 1 year"

    event.repeat = "yearly"
    events = event.events_in_range(start.at_beginning_of_year, start.at_beginning_of_year + 2.years)
    assert_equal 2, events.length, "yearly event should only repeat 2 times in 2 years"
  end

  test "events can occur on certain days" do
    start_date = DateTime.current.at_beginning_of_week
    end_date = DateTime.current.at_end_of_week

    event = events(:repeat_daily)
    event.repeat = "certain_days-1,3,4,5" # M,W,R,F, totally an implementation detail
    event.repeat_start = start_date
    event.repeat_end = end_date

    assert_equal 4, event.events_in_range(start_date, end_date).length,
                 "event should only repeat on 4/7 days of the week"
  end

  test "events with an improper repeat field just do not repeat" do
    event = events(:repeat_daily)
    event.repeat = "noot"
    event.date = 1.hour.from_now
    event.end_date = 2.hours.from_now

    event.repeat_start = DateTime.current
    event.repeat_end = 3.days.from_now

    events = event.events_in_range 1.week.ago.to_date, 1.week.from_now.to_date
    assert_equal 1, events.length
  end

  test "custom repeat events work" do
    event = events(:repeat_daily)

    # event is set for monday morning
    start = event.date.to_datetime.at_beginning_of_week
    event.date = start + 1.hour
    event.end_date = start + 2.hours
    event.repeat_start = start

    # every n days
    event.repeat = "custom-2-days" # implementation detail
    event.repeat_end = start + 1.week

    # the event should occur on monday, wednesday, friday, and sunday.
    assert_equal 4, event.events_in_range(start, start + 1.week).length,
                 "event should appear every other day of the week"

    # every n weeks
    event.repeat = "custom-2-weeks"
    event.repeat_end = start + 4.weeks

    assert_equal 3, event.events_in_range(start, start + 4.weeks).length,
                 "event should appear every other week over the course of the next 4 weeks"

    # every n months
    event.repeat = "custom-2-months"
    event.repeat_end = start + 4.months

    assert_equal 3, event.events_in_range(start, start + 4.month).length

    # every n years
    event.repeat = "custom-2-years"
    event.repeat_end = start + 3.years

    assert_equal 2, event.events_in_range(start, start + 3.year).length
    assert_empty event.events_in_range(start - 2.hour, start - 1.hour)
  end
end
