require 'test_helper'

class ScheduleControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "signed in users can delete their event" do
    sign_in users(:norm)
    get :delete_event, params: { id: 101 }
    assert_response :success
  end

  test "group owner can add categories" do
    sign_in users(:ownerAlice)

    assert_difference -> { Category.count }, +1 do
      post :create_category, params: { group_id: groups(:publicGroup).id,
                                       name: "cool category" }
    end
  end

  test "group moderator can add categories" do
    sign_in users(:moderatorMaven)

    assert_difference -> { Category.count }, +1 do
      post :create_category, params: { group_id: groups(:publicGroup).id,
                                       name: "cool category" }
    end
  end

  test "group memeber cannot add categories" do
    sign_in users(:memberMike)

    assert_no_difference -> { Category.count } do
      post :create_category, params: { group_id: groups(:publicGroup).id,
                                       name: "cool category" }
    end
  end

  test "non-group memebers cannot add categories" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Category.count } do
      post :create_category, params: { group_id: groups(:publicGroup).id,
                                       name: "cool category" }
    end
  end

  test "group owner can delete categories" do
    sign_in users(:ownerAlice)

    assert_difference -> { Category.count }, -1 do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
  end
  
  test "group moderator can delete categories" do
    sign_in users(:moderatorMaven)

    assert_difference -> { Category.count }, -1 do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
  end

  test "group memeber cannot delete categories" do
    sign_in users(:memberMike)

    assert_no_difference -> { Category.count } do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
  end

  test "group non-member can delete categories" do
    sign_in users(:loserLarry)

    assert_no_difference -> { Category.count } do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
  end

  test "group owner can add events" do
    user = users(:ownerAlice)
    sign_in user

    assert_difference -> { Event.count }, +1 do
      post :save_events, params: { map: {one: {eventId: "", group_id: groups(:publicGroup).id, startDateTime: Date.current, endDateTime: Date.current}} }
    end
    sign_out user
  end

  test "group moderator can add events" do
    user = users(:moderatorMaven)
    sign_in user

    assert_difference -> { Event.count }, +1 do
      post :save_events, params: { map: {one: {eventId: "", group_id: groups(:publicGroup).id, startDateTime: Date.current, endDateTime: Date.current}} }
    end
    sign_out user
  end

  test "group memeber can add events" do
    user = users(:memberMike)
    sign_in user

    assert_difference -> { Event.count }, +1 do
      post :save_events, params: { map: {one: {eventId: "", group_id: groups(:publicGroup).id, startDateTime: Date.current, endDateTime: Date.current}} }
    end
    sign_out user
  end

  test "group non-memeber cannot add events" do
    user = users(:loserLarry)
    sign_in user

    assert_no_difference -> { Event.count } do
      post :save_events, params: { map: {one: {eventId: "", group_id: groups(:publicGroup).id, startDateTime: Date.current, endDateTime: Date.current}} }
    end
    sign_out user
  end

  test "group owner can delete events" do
    user = users(:ownerAlice)
    sign_in user

    assert_difference -> { Event.count }, -1 do
      post :delete_event, params: { id: events(:public_group_event) }
    end
    sign_out user
  end
  
  test "group moderator can delete events" do
    user = users(:moderatorMaven)
    sign_in user

    assert_difference -> { Event.count }, -1 do
      post :delete_event, params: { id: events(:public_group_event) }
    end
    sign_out user
  end

  test "group memeber can delete events" do
    user = users(:memberMike)
    sign_in user

    assert_difference -> { Event.count }, -1 do
      post :delete_event, params: { id: events(:public_group_event) }
    end
    sign_out user
  end

  test "group non-member can delete events" do
    user = users(:loserLarry)
    sign_in user

    assert_no_difference -> { Event.count } do
      post :delete_event, params: { id: events(:public_group_event) }
    end
    sign_out user
  end

end