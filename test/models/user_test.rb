# To run all tests, in the project directory run the command:
# bundle exec rails test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rails test test/controllers/event_test.rb

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @viktor, @norm, @putin = users(:viktor, :norm, :putin)

    @curr_event_1 = events(:current_event_1)
    @curr_event_2 = events(:current_event_2)
    @curr_event_3 = events(:current_event_3)
  end

  test "follow and unfollow should work" do
    assert_not @norm.following?(@viktor),
               "Users should not be following each other by default."

    @norm.follow(@viktor)
    @viktor.confirm_follow(@norm)

    assert @norm.following?(@viktor),
           "Following a user does not work, at least by '.following?'"

    @norm.unfollow(@viktor)
    assert_not @norm.following?(@viktor),
               "Unfollowing a user does not work, at least by '.following?'"
  end

  test "deny_follow should remove following status" do
    @norm.follow(@viktor)
    @viktor.confirm_follow(@norm)
    @viktor.deny_follow(@norm) # guess he changed his mind?

    assert_not @norm.following?(@viktor),
               "Denying a follower does not remove their follower status"
  end

  test "should follow public profiles without confirmation" do
    @norm.follow(@putin)
    assert @norm.following?(@putin),
           "Public profile was not be followed automatically"
  end

  test "'Private' and 'Follower' category items should not be given to unrelated users" do
    result = @viktor.get_categories(@putin).find { |cat| cat == categories(:private) }
    assert_includes result.name, "Private",
                    "Private categories should not be visible to other users"

    result = @viktor.get_categories(@putin).find { |cat| cat == categories(:followers) }
    assert_includes result.name, "Private",
                    "Follower categories should not be visible to non-following users"
  end

  test "has_custom_url should return whether or not the user has a custom url" do
    assert_not @norm.has_custom_url?,
               "has_custom_url returning true for users not using a custom url"
  end

  # TODO: is this actually the desired behaviour?
  test "events_in_range only uses the event starting date (rather than a range)" do
    @curr_event_1.date     = 1.hour.from_now
    @curr_event_1.end_date = 3.hours.from_now
    @curr_event_1.save!

    included = @norm.events_in_range DateTime.current, 2.hours.from_now
    assert_not_empty included

    excluded = @norm.events_in_range 2.hours.from_now, 4.hours.from_now
    assert_empty excluded
  end

  test "events_in_range includes repeating events" do
    daily = events(:repeat_daily)
    from  = daily.date.to_datetime - 1.hour
    to    = daily.date.to_datetime + 1.hour

    base_event = @viktor.events_in_range(from, to).first
    assert_equal daily.name, base_event.name

    repeat_event = @viktor.events_in_range(from + 1.year, to + 1.year).first
    assert_equal daily.name, repeat_event.name
  end

  test "should be able to make a user with name, email, and password" do
    test_user          = User.new
    test_user.name     = "test"
    test_user.email    = "test@email.com"
    test_user.password = "password"
    assert test_user.save!, "Can save a user with only name"
  end

  test "should be able to make a user with custom URL" do
    test_user            = User.new
    test_user.name       = "test"
    test_user.email      = "test@email.com"
    test_user.password   = "password"
    test_user.custom_url = "thecooltester"
    assert test_user.save!, "Can save a user with custom URL"
  end

  test "should not be able to make a user with numeric custom URL" do
    @norm.custom_url = "1234"
    assert_not @norm.valid?, "User with numeric custom URL is not valid"
  end

  test "should be able to make a custom URL with numbers" do
    @norm.custom_url = "norm007"
    assert @norm.valid?, "User with custom URL is valid"
  end

  test "current_events should return events in progress" do
    # First event that we make into a current event; this one should be first in
    # the current events array, since it ends in one hour from the current time
    # (the time when the test is run), and the list is sorted by ending time
    @curr_event_1.date     = 1.hour.ago
    @curr_event_1.end_date = 1.hour.from_now
    @curr_event_1.save!

    # This will be second in the current events array, since it ends in two hours
    @curr_event_2.date     = 2.hours.ago
    @curr_event_2.end_date = 2.hours.from_now
    @curr_event_2.save!

    # This will be a non-current event - a negative test case.
    @curr_event_3.date     = 2.hours.from_now
    @curr_event_3.end_date = 4.hours.from_now
    @curr_event_3.save!

    # Get the list of current events from the function we're testing
    current_events = @norm.current_events

    # We created two test events as current events, so make sure we only got
    # two events back from the function call
    assert_equal 2, current_events.length,
                 "Got wrong number of current events"

    # Make sure we got the right event as the first event (to check sorting order,
    # and make sure that we didn't get any events returned as "current events" that
    # shouldn't be)
    assert_equal @curr_event_1, current_events[0],
                 "First current event is wrong or out of order"

    # Make sure that second event is also the right one, and in the right order
    assert_equal @curr_event_2, current_events[1],
                 "Secord current event is wrong or out of order"
  end

  test "next_event should return events within current day" do
    # three events - one yesterday, two today

    # This is the yesterday event
    @curr_event_1.date     = 30.hours.ago
    @curr_event_1.end_date = 28.hours.ago
    @curr_event_1.save!

    # This event is currently going on, but not the next event
    @curr_event_2.date     = 1.hour.ago
    @curr_event_2.end_date = 1.hour.from_now
    @curr_event_2.save!

    # This event should be the next event
    @curr_event_3.date     = 1.hour.from_now
    @curr_event_3.end_date = 2.hours.from_now
    @curr_event_3.save!

    # Make sure that the next event is the right one
    assert_equal @curr_event_3, @norm.next_event,
                 "Wrong event was returned as the next event!"
  end

  test "is_busy should reflect user's current events" do
    # Make two events - one currently going on, one not
    @curr_event_1.date     = 2.hours.ago
    @curr_event_1.end_date = 1.hour.from_now
    @curr_event_1.save!

    @curr_event_2.date     = 36.hours.from_now
    @curr_event_2.end_date = 38.hours.from_now
    @curr_event_2.save!

    assert @norm.is_busy?,
           "One event is going on. 'is_busy?' should have returned true"
  end

  test "users can be destroyed" do
    @norm.destroy
    assert_empty @norm.events, "All associated events should have been destroyed"
    assert_empty @norm.active_relationships, "User relationships should have been destroyed"
    assert_not @norm.persisted?, "User should be marked as destroyed/deleted"
  end

  test "has_avatar returns true when a profile has an avatar" do
    assert @putin.has_avatar, "Returned false despite user having an avatar"
    assert_not @norm.has_avatar, "Returned true despite user not having an avatar"
  end

  test "user_avatar returns custom avatar url" do
    @viktor.avatar = File.new("test/fixtures/sample_avatar.jpg")
    @viktor.save!

    assert_includes @viktor.user_avatar(30), "sample_avatar", "avatar thumbnails don't work"
    assert_includes @viktor.user_avatar(200), "sample_avatar", "avatar photos don't work"
  end

  test "provider_name formats provider names as expected" do
    # missing provider names should just return nil
    @putin.provider = nil
    assert_nil @putin.provider_name

    # unknown provider names should simply return themselves
    @putin.provider = "cool_beans"
    assert_equal "cool_beans", @putin.provider_name

    # known provider names should return a nicely formatted string...
    @putin.provider = "google_oauth2"
    assert_instance_of String, @putin.provider_name
  end

  test "follow_status returns the appropriate constant for each status" do
    @norm.follow(@putin) # putin has a public profile
    assert_equal "confirmed", @norm.follow_status(@putin)

    @putin.follow(@norm) # norm has a private profile
    assert "pending", @putin.follow_status(@norm)
  end

  test "rank sorts users properly" do
    users = [users(:donald1), users(:donald2), users(:donald3)] # the correct order of users
    shuffled_users = users.shuffle # create random list of these users, always should have same order
    assert_equal User.rank(users, "donald"), users
  end

  test "convert_to_json doesn't return IP fields" do
    users(:viktor).current_sign_in_ip = "192.168.1.1" # set sign in IP on user
    users(:viktor).encrypted_password = "EnCryptedPassword" # set encrypted password on user

    assert_not_nil users(:viktor).current_sign_in_ip, "test user should have a sign in IP"
    assert_not_empty users(:viktor).encrypted_password, "test user should have an encrypted password"

    assert_nil users(:viktor).convert_to_json["current_sign_in_ip"], "convert_to_json should not contain sign in IP"
    assert_nil users(:viktor).convert_to_json["encrypted_password"], "convert_to_json should not contain encrypted_password"
  end

  test "next_event shouldn't return past events" do
    event = events(:current_event_1)
    event.date = Time.parse('4th Jun 2018 10:00:00 PM')
    event.end_date = event.date + 2.hour
    event.repeat = "certain_days-0" # repeat every sunday

    event.save!
    event.reload

    current_time = Time.parse('28th May 2018 5:00:00 PM') # a monday
    travel_to current_time do
      next_event = users(:norm).next_event
      assert_nil next_event, "found 'current event' date #{next_event&.date} between #{Time.current} and #{1.day.from_now}"
    end
  end
end