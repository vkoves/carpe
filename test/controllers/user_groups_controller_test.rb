require 'test_helper'

class UserGroupsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "not signed in users can not join public groups" do
    user = users(:joe)
    get :join_group, params: {user_id: user.id, group_id: groups(:four).id }
    assert !groups(:three).in_group?(user)
  end

  test "signed in users can join secret groups they were invited to" do
    user = users(:joe)
    sign_in user
    get :join_group, params: {user_id: user.id, group_id: groups(:four).id }
    assert groups(:three).in_group?(user)
  end

  test "signed in users can join public groups" do
    user = users(:joe)
    sign_in user
    get :join_group, params: { user_id: user.id, group_id: groups(:four).id }
    assert groups(:three).in_group?(user)
  end
end