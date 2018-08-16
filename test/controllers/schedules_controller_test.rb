require 'test_helper'

UNSAVED_EVENT = "" # unsaved events on the scheduler without an id use this value

class SchedulesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    # this gets created when a user makes a new event on their scheduler
    @unsaved_events = {
      events: [
        { eventId: UNSAVED_EVENT, groupId: groups(:publicGroup).id, startDateTime: Date.current, endDateTime: Date.current }
      ],
    }
  end

  test "group owner can add events" do
    sign_in users(:ownerAlice)

    assert_difference -> { Event.count }, +1 do
      post save_schedule_path, params: @unsaved_events
    end
  end

  test "group moderator can add events" do
    sign_in users(:moderatorMaven)

    assert_difference -> { Event.count }, +1 do
      post save_schedule_path, params: @unsaved_events
    end
  end

  test "group memeber can add events" do
    sign_in users(:memberMike)

    assert_difference -> { Event.count }, +1 do
      post save_schedule_path, params: @unsaved_events
    end
  end

  test "non-group member cannot add events" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Event.count } do
      post save_schedule_path, params: @unsaved_events
    end
  end
end