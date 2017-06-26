# To run all tests, in the project directory run the command:
# bundle exec rake test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rake test test/controllers/event_test.rb

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should follow and unfollow a user" do
    norm = users(:norm) # Grab our two users
    viktor = users(:viktor)

    assert_not norm.following?(viktor), "Users should not be following each other by default." # By default, Norm should not be following Viktor

    norm.follow(viktor) # Have Norm follow Viktor
    viktor.confirm_follow(norm) # and Viktor confirm the follow

    assert norm.following?(viktor), "Following a user does not work, at least by \".following?\"" # after that, Norm should be following Viktor

    norm.unfollow(viktor) # Then have Norm unfollow Viktor
    assert_not norm.following?(viktor), "Unfollowing a user does not work, at least by \".following?\"" # and check it worked
  end

  test "should be able to make a user with name, email, and password" do
    test_user = User.new
    test_user.name = "test"
    test_user.email = "test@email.com"
    test_user.password = "password"
    assert_equal(test_user.save!, true, "Can save a user with only name")
  end

  test "should be able to make a user with custom URL" do
    test_user = User.new
    test_user.name = "test"
    test_user.email = "test@email.com"
    test_user.password = "password"
    test_user.custom_url = "thecooltester"
    assert_equal(test_user.save!, true, "Can save a user with custom URL")
  end

  test "should not be able to make a user with numeric custom URL" do
    users(:norm).custom_url = "1234"
    assert_equal(users(:norm).valid?, false, "User with numeric custom URL is not valid")
  end

  test "should be able to make a custom URL with numbers" do
    users(:norm).custom_url = "norm007"
    assert_equal(users(:norm).valid?, true, "User with custom URL is valid")
  end

  test "current_events should return events in progress" do
    viktor = users(:viktor)
    curr_event_1 = events(:current_event_1)
    curr_event_2 = events(:current_event_2)

    # First event that we make into a current event; this one should be first in
    # the current events array, since it ends in one hour from the current time
    # (the time when the test is run), and the list is sorted by ending time
    curr_event_1.date = DateTime.now - 1.hour
    curr_event_1.end_date = DateTime.now + 1.hour
    curr_event_1.save

    # This will be second in the current events array, since it ends in two hours
    curr_event_2.date = DateTime.now - 2.hour
    curr_event_2.end_date = DateTime.now + 2.hour
    curr_event_2.save

    # Get the list of current events from the function we're testing
    current_events = viktor.current_events

    # We created two test events as current events, so make sure we only got
    # two events back from the function call
    assert_equal(2, current_events.length, "Got wrong number of current events compared to the test data! (should be two)")

    # Make sure we got the right event as the first event (to check sorting order,
    # and make sure that we didn't get any events returned as "current events" that
    # shouldn't be)
    assert_equal(curr_event_1, current_events[0], "First current event is wrong; either we got a wrong current event, or the current events are in the wrong order.")

    # Make sure that second event is also the right one, and in the right order
    assert_equal(curr_event_2, current_events[1], "Second current event is wrong; either we got a wrong current event, or the current events are in the wrong order.")
  end

  test "next_event should return events within current day" do
    viktor = users(:viktor)
    curr_event_1 = events(:current_event_1)
    curr_event_2 = events(:current_event_2)
    curr_event_3 = events(:current_event_3)

    # Make three events - one yesterday, two today
    #
    # This is the yesterday event
    curr_event_1.date = DateTime.now - 30.hour
    curr_event_1.end_date = DateTime.now - 28.hour
    curr_event_1.save

    # This event is currently going on, but not the next event
    curr_event_2.date = DateTime.now - 1.hour
    curr_event_2.end_date = DateTime.now + 1.hour
    curr_event_2.save

    # This event should be the next event
    curr_event_3.date = DateTime.now + 1.hour
    curr_event_3.end_date = DateTime.now + 2.hour
    curr_event_3.save

    # Make sure that the next event is the right one
    assert_equal(curr_event_3, viktor.next_event, "Wrong event was returned as the next event!")
  end

  test "is_busy should reflect user's current events" do
    viktor = users(:viktor)
    curr_event_1 = events(:current_event_1)
    curr_event_2 = events(:current_event_2)

    # Make two events - one currently going on, one not
    curr_event_1.date = DateTime.now - 2.hour
    curr_event_1.end_date = DateTime.now + 1.hour
    curr_event_1.save

    curr_event_2.date = DateTime.now + 36.hour
    curr_event_2.end_date = DateTime.now + 38.hour
    curr_event_2.save

    assert_equal(true, viktor.is_busy?, "Test data has one event currently going on, \"is_busy?\" should have returned true!")
  end
end
