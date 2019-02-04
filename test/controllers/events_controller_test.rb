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

    assert_difference -> { EventInvite.count }, +1 do
      post setup_hosting_event_path(events(:simple))
    end

    assert_response :success
  end
end
