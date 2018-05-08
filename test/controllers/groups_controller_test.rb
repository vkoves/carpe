require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "user must be signed in to see groups" do
    get :index
    assert_response :redirect
  end

  test "signed in users can see groups" do
    sign_in users(:norm)
    get :index
    assert_response :success
  end

  test "user must be signed in to see public group" do
    get :show, params: {id:groups(:three).id}
    assert_response :redirect
  end

  test "signed in users can see a public group" do
    sign_in users(:norm)
    get :show, params: {id:groups(:three).id}
    assert_response :success
  end

  test "users not in secret group cant see it" do
    sign_in users(:norm)
    get :show, params: {id:groups(:four).id}
    assert_response :redirect
  end

  test "users in secret group can see it" do
    sign_in users(:joe)
    get :show, params: {id:groups(:four).id}
    assert_response :success
  end

  test "user must be signed in to create a group" do
    get :create
    assert_response :redirect
  end

  test "signed in users can create a group" do
    sign_in users(:norm)
    assert_difference 'Group.count', +1 do
      get :create, params: { group: { name: "Test Group" } }
    end
  end
end