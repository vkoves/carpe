require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "signed in users can delete their events" do
    sign_in users(:norm)
    delete event_path(events(:event_to_delete))
    assert_response :success
  end

  test "group member can delete events" do
    sign_in users(:memberMike)

    assert_difference -> { Event.count }, -1 do
      delete event_path(events(:public_group_event))
    end
  end

  test "group moderator can delete events" do
    sign_in users(:moderatorMaven)

    assert_difference -> { Event.count }, -1 do
      delete event_path(events(:public_group_event))
    end
  end

  test "group owner can delete events" do
    sign_in users(:ownerAlice)

    assert_difference -> { Event.count }, -1 do
      delete event_path(events(:public_group_event))
    end
  end

  test "non-group members cannot delete events" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Event.count } do
      delete event_path(events(:public_group_event))
    end
  end

  test "plain events can be initialized into host events" do
    sign_in users(:viktor)

    # the host gets invited to their own event
    assert_difference -> { EventInvite.count }, +1 do
      post setup_hosting_event_path(events(:simple))
    end

    assert_response :success
  end

  test "event host can destroy original event" do
    sign_in users(:viktor)

    # Assert Viktor has one less event, since we don't know guest count and
    # those events also get deleted
    assert_difference -> { users(:viktor).events.count }, -1 do
      delete event_path(events(:music_convention))
    end

    assert_response :success
  end

  test "event guest cannot destroy original event" do
    sign_in users(:joe)

    # Assert Viktor has the same amount of events to confirm the original event
    # did not change
    assert_no_difference -> { users(:viktor).events.count } do
      delete event_path(events(:music_convention))
    end

    assert_response :redirect
  end

  test "event guest can destroy their host event" do
    sign_in users(:joe)

    # Assert Joe has one less event
    assert_difference -> { users(:joe).events.count }, -1 do
      delete event_path(events(:music_convention_joe))
    end

    assert_response :success
  end

  test "event guest destroying their host event removes them from guest list" do
    sign_in users(:joe)

    # Assert the main event has one less guest
    assert_difference -> { events(:music_convention).invited_users.count }, -1 do
      delete event_path(events(:music_convention_joe))
    end

    assert_response :success
  end

  test "event host shouldn't receive an event invitation email" do
    sign_in users(:viktor)

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      post setup_hosting_event_path(events(:simple))
    end
  end

  test "event owner can host their event" do
    sign_in users(:viktor)
    event = events(:simple) # owned by viktor

    post setup_hosting_event_path(event)
    assert_response :success
  end

  test "users cannot host other users' events" do
    sign_in users(:putin)
    event = events(:simple) # owned by viktor

    post setup_hosting_event_path(event)
    assert_response :redirect
  end
end
