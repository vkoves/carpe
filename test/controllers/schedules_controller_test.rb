require "test_helper"

class ScheduleControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    # this gets created when a user makes a new event on their scheduler
    @unsaved_events = {
      events: [
        {
          eventId: "", categoryId: categories(:groupCategory).id,
          groupId: groups(:publicGroup).id,
          startDateTime: Date.current, endDateTime: Date.current
        }
      ]
    }
  end

  test "user can make an event" do
    test_user = users(:viktor)

    sign_in test_user

    unsaved_event = {
      events: [
        categoryId: test_user.categories.first.id,
        startDateTime: Date.current, endDateTime: Date.current
      ]
    }

    assert_difference -> { test_user.events.count }, +1 do
      post save_schedule_path, params: unsaved_event
    end

    assert_response :success
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

  test "group member can add events" do
    sign_in users(:memberMike)

    assert_difference -> { Event.count }, +1 do
      post save_schedule_path, params: @unsaved_events
    end
  end

  test "non-group member cannot add events" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Event.count } do
      post save_schedule_path, params: @unsaved_events, as: :json
    end
  end

  test "event guest cannot change their hosted event's details" do
    host_event_id = events(:music_convention_joe).id
    sign_in users(:joe)

    edits = {
      events: [
        eventId: host_event_id,
        description: 'Some new description',
        startDateTime: Date.current, endDateTime: Date.current,
        categoryId: users(:joe).categories.first.id
      ]
    }

    assert_no_changes -> { Event.find(host_event_id).description } do
      post save_schedule_path, params: edits, as: :json
    end

    assert_response 403 # Unauthorized error
  end

  test "event guest can change their hosted event's category" do
    host_event_id = events(:music_convention_joe).id
    sign_in users(:joe)

    edits = {
      events: [
        eventId: host_event_id,
        description: events(:music_convention_joe).description,
        categoryId: users(:joe).categories.last.id,
        startDateTime: events(:music_convention_joe).date,
        endDateTime: events(:music_convention_joe).end_date,
      ]
    }

    assert_changes -> { Event.find(host_event_id).category } do
      post save_schedule_path, params: edits, as: :json
    end

    assert_response :success
  end
end
