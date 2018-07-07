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

end