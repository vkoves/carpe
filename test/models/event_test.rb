# To run all tests, in the project directory run the command:
# bundle exec rails test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rails test test/models/event_test.rb

require "test_helper"

class EventTest < ActiveSupport::TestCase
  def setup
    @daily = events(:repeat_daily)
    @morning = @daily.date.at_beginning_of_day
  end

  test "repeat start and end shouldn't impact original event if repeat type is none" do
    event = events(:repeat_none_with_start_and_end)
    repeat_events = event.events_in_range event.date - 2.days, event.end_date + 2.days
    assert_equal 1, repeat_events.length
  end

  test "users should have access to their own events" do
    assert categories(:private).accessible_by?(users(:viktor)),
           "user does not have access to their own events (according to accessible_by?)"
  end

  test "private_version should return an event with its details hidden" do
    private_event = events(:simple).private_version
    assert_empty private_event.description, "event details were not hidden"
  end

  test "repeat clones should have proper date" do
    # DateTime is needed here, otherwise things just won't work
    # rubocop:disable DateTime
    start_date = (@daily.date - 2.days).to_datetime
    end_date = (@daily.end_date + 2.days).to_datetime
    repeat_dates = (start_date...end_date).map(&:to_date)
    # rubocop:enable DateTime

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

  test "events_in_range should work with 1 directional infinite repeats" do
    @daily.repeat_start = @morning
    @daily.repeat_end = nil
    events = @daily.events_in_range(@morning - 5.days, @morning + 77.days)

    assert_equal 77, events.length
  end

  test "events_in_range should not include repeat events that are on break" do
    exception = repeat_exceptions(:one)

    exception.start = @morning
    exception.end = @morning.at_end_of_day + 2.days
    @daily.repeat_exceptions << exception

    events = @daily.events_in_range(@morning, @morning.at_end_of_day + 3.days)
    assert_equal 1, events.length, "repeated events that are on break not being excluded"
  end

  # DST EXPLAINED
  #
  # Chicago's time zone is Central Standard Time (CST); except, between dates such as
  # March 12, 2017 at 2:00am - November 5, 2:00am, Chicago is in Daylight Savings Time (DST).
  # When Chicago is in DST its clock "moves ahead 1 hour".
  test "you understand how daylight savings works" do
    user_time_zone = Time.find_zone("America/Chicago")

    # typically we're given a time from a user and store it in the database in UTC time.
    time_before_dst = user_time_zone.parse("1st March 2018 4:00:00 PM").utc
    assert_equal "10:00 PM", time_before_dst.strftime("%I:%M %p") # CST -> UTC offset is +6 hours

    # Now, UTC doesn't care about DST. If we go from CST to DST, it doesn't care.
    time_after_dst = time_before_dst + 1.month
    assert_equal "10:00 PM", time_after_dst.strftime("%I:%M %p")

    # When converting back into a time zone it *does* care, though.
    assert_equal "05:00 PM", time_after_dst.in_time_zone(user_time_zone).strftime("%I:%M %p")

    # If our goal is to get a UTC time that represents 4:00 PM regardless of DST, then
    # we must put our original date in the context of a time zone before generating any new
    # dates relative to the original date.
    test_time = time_before_dst.in_time_zone(user_time_zone) + 1.month
    assert_equal "04:00 PM", test_time.strftime("%I:%M %p")

    # Sure enough, the UTC time has been adjusted.
    assert_equal "09:00 PM", test_time.utc.strftime("%I:%M %p")

    # This is important because repeat events may have some dates that
    # occur in DST while others don't. Thus, the 'date' property of clones,
    # which is stored in UTC, must be adjusted in the same way this example was
    # to ensure that all clone occur at the same time as the origin event.
  end

  # see DST EXPLAINED
  test "events_in_range_fixed_timestep preserves event time across DST" do
    zone = Time.find_zone("America/Chicago")
    @daily.date = zone.parse("12th Mar 2017 01:00:00 AM") # event occurs before DST
    @daily.end_date = @daily.date + 1.hour

    # get events before and after DST goes into effect
    events = @daily.events_in_range(@daily.date, @daily.date + 2.days, zone)

    assert_equal 1, events.first.date.in_time_zone(zone).hour
    assert_equal 1, events.last.date.in_time_zone(zone).hour
  end

  # see DST EXPLAINED
  test "dates_in_range_certain_weekdays preserves event time across DST" do
    zone = Time.find_zone("America/Chicago")

    event = events(:current_event_1)
    event.date = zone.parse("1st March 2018 7:00:00 PM") # event created before DST
    event.end_date = event.date + 2.hour
    event.repeat = "certain_days-1" # repeat every monday

    # get events after DST has gone into effect
    events = event.events_in_range(Date.new(2018, 6, 4), Date.new(2018, 6, 10), zone)
    event_time = events.first.date.in_time_zone(zone).strftime("%I:%M %p")

    assert_equal "07:00 PM", event_time
  end

  test "events can be repeated daily, weekly, monthly, and yearly" do
    event = events(:repeat_daily)
    start = event.date
    event.end_date = start + 2.hours

    event.repeat = "daily"
    events = event.events_in_range start, start + 4.days
    assert_equal 4, events.length, "daily event should only repeat 4 times in 4 days"

    events = event.events_in_range start, start + 4.days + 3.hours
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
    start_date = Time.current.at_beginning_of_week
    end_date = Time.current.at_end_of_week

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

    event.repeat_start = Time.current
    event.repeat_end = 3.days.from_now

    events = event.events_in_range 1.week.ago.to_date, 1.week.from_now.to_date
    assert_equal 1, events.length
  end

  test "custom repeat events work" do
    event = events(:repeat_daily)

    # event is set for monday morning
    start = event.date.beginning_of_week
    event.date = start + 1.hour
    event.end_date = start + 2.hours
    event.repeat_start = start

    # every n days
    event.repeat = "custom-2-days" # implementation detail
    event.repeat_end = start + 1.week

    assert_equal 4, event.events_in_range(start, start + 1.week).length

    # negative test
    assert_empty event.events_in_range(start - 4.weeks, start - 2.weeks),
                 "events_in_range returned events outside of the event's range"

    assert_empty event.events_in_range(start + 2.weeks, start  + 4.weeks),
                 "events_in_range returned events outside of the event's range"

    # randomly specific test
    assert_equal 2, event.events_in_range(start - 2.day, start + 4.days).length

    # every n weeks
    event.repeat = "custom-2-weeks"
    event.repeat_end = start + 4.weeks

    assert_equal 2, event.events_in_range(start, start + 4.weeks).length,
                 "event should appear every other week over the course of the next 4 weeks"

    # negative test
    assert_empty event.events_in_range(start - 4.weeks, start - 2.weeks),
                 "events_in_range returned events outside of the event's range"

    # every n months
    event.repeat = "custom-2-months"
    event.repeat_end = start + 4.months

    assert_equal 2, event.events_in_range(start, start + 4.month).length

    # negative test
    assert_empty event.events_in_range(start - 4.weeks, start - 2.weeks),
                 "events_in_range returned events outside of the event's range"

    # every n years
    event.repeat = "custom-2-years"
    event.repeat_end = start + 3.years

    assert_equal 2, event.events_in_range(start, start + 3.year).length

    # negative test
    assert_empty event.events_in_range(start - 4.weeks, start - 2.weeks),
                 "events_in_range returned events outside of the event's range"
  end

  test "events that repeat yearly appear on the correct dates" do
    event = events(:simple)
    event.date = Date.new(2015, 10, 21)
    event.end_date = event.date + 1.day
    event.repeat = "yearly"

    clone_date = event.events_in_range(Date.new(2017, 10, 1), Date.new(2017, 10, 30)).first.date.to_date
    assert_equal Date.new(2017, 10, 21), clone_date

    assert_equal 1, event.events_in_range(Date.new(2017, 10, 7), Date.new(2017, 10, 28)).length

    # negative tests:
    # in right day range but wrong month
    assert_empty event.events_in_range(Date.new(2017, 7, 1), Date.new(2017, 7, 30))

    # in right month but before event
    assert_empty event.events_in_range(Date.new(2017, 10, 7), Date.new(2017, 10, 20))
    assert_empty event.events_in_range(Date.new(2017, 10, 13), Date.new(2017, 10, 20))

    # in right month but after event
    assert_empty event.events_in_range(Date.new(2017, 10, 22), Date.new(2017, 10, 29))
  end

  test "changing event gives guest a notification" do
    event = events(:music_convention) # Has several invited users, but we just check one
    guest = users(:norm)

    event.name += " Changed"
    event.save

    # Ensure there is one notification for this event being updated
    assert Notification.exists?(
      entity: event,
      receiver: guest,
      event: Notification.events["event_update"]
    )
  end

  test "changing event does not notify current user" do
    current_user = Current.user = users(:viktor) # set current user globals
    event = events(:music_convention) # Has several invited users, but we just check one

    event.name += " Changed"
    event.save

    # Ensure there are no notifications for this event being updated
    assert_not Notification.exists?(
      entity: event,
      receiver: current_user,
      event: Notification.events["event_update"]
    )
  end

  test "changing host(ed) event category should not notify guests" do
    event = events(:music_convention)

    assert_no_difference -> { Notification.count } do
      event.update!(category: categories(:followers))
    end
  end

  test "deleting host event removes hosted event" do
    host_event = events(:music_convention) # owned by viktor

    assert_difference -> { Event.count }, -2 do
      host_event.destroy!
    end
  end

  test "deleting a hosted event removes the associated invite" do
    hosted_event = events(:music_convention_joe)

    assert_difference -> { EventInvite.count }, -1 do
      hosted_event.destroy!
    end
  end

  test "updating a host event updates associated hosted events" do
    host_event = events(:music_convention)
    hosted_event = events(:music_convention_joe)

    host_event.update! name: "Pub Crawl"
    hosted_event.reload

    assert_equal "Pub Crawl", hosted_event.name
  end
end
