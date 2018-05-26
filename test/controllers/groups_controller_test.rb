require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "user must be signed in to create a group" do
    get :create
    assert_response :redirect
  end

  test "signed in users can create a group" do
    sign_in users(:norm)
    assert_difference 'Group.count', +1 do
      get :create, params: { name: "Test Group" }
    end
  end
end