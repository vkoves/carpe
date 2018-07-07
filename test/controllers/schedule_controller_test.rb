require 'test_helper'

class ScheduleControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "signed in users can delete their event" do
    sign_in users(:norm)
    get :delete_event, params: { id: 101 }
    assert_response :success
  end

  # create

  test "group owner can add categories" do
    user = users(:ownerAlice)
    sign_in user

    assert_difference -> { Category.count }, +1 do
      post :create_category, params: { group_id: groups(:publicGroup).id, name: "cool category" }
    end
    sign_out user
  end

  test "group moderator can add categories" do
    user = users(:moderatorMaven)
    sign_in user

    assert_difference -> { Category.count }, +1 do
      post :create_category, params: { group_id: groups(:publicGroup).id, name: "cool category" }
    end
    sign_out user
  end

  test "group memeber cannot add categories" do
    user = users(:memberMike)
    sign_in user

    assert_no_difference -> { Category.count } do
      post :create_category, params: { group_id: groups(:publicGroup).id, name: "cool category" }
    end
    sign_out user
  end

  test "group non-memeber cannot add categories" do
    user = users(:loserLarry)
    sign_in user

    assert_no_difference -> { Category.count } do
      post :create_category, params: { group_id: groups(:publicGroup).id, name: "cool category" }
    end
    sign_out user
  end

  test "group owner can delete categories" do
    user = users(:ownerAlice)
    sign_in user

    assert_difference -> { Category.count }, -1 do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
    sign_out user
  end
  
  test "group moderator can delete categories" do
    user = users(:moderatorMaven)
    sign_in user

    assert_difference -> { Category.count }, -1 do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
    sign_out user
  end

  test "group memeber cannot delete categories" do
    user = users(:memberMike)
    sign_in user

    assert_no_difference -> { Category.count } do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
    sign_out user
  end

  test "group non-member can delete categories" do
    user = users(:loserLarry)
    sign_in user

    assert_no_difference -> { Category.count } do
      post :delete_category, params: { id: categories(:groupCategory) }
    end
    sign_out user
  end

end