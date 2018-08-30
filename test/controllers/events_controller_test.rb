require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "signed in users can delete their events" do
    sign_in users(:norm)
    delete event_path(events(:event_to_delete)), as: :json
    assert_response :success
  end

  test "group member can delete events" do
    sign_in users(:memberMike)

    assert_difference -> { Event.count }, -1 do
      delete event_path(events(:public_group_event)), as: :json
    end
  end

  test "group moderator can delete events" do
    sign_in users(:moderatorMaven)

    assert_difference -> { Event.count }, -1 do
      delete event_path(events(:public_group_event)), as: :json
    end
  end

  test "group owner can delete events" do
    sign_in users(:ownerAlice)

    assert_difference -> { Event.count }, -1 do
      delete event_path(events(:public_group_event)), as: :json
    end
  end

  test "non-group members cannot delete events" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Event.count } do
      delete event_path(events(:public_group_event)), as: :json
    end
  end
end
