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

  test "not signed in users can not join public groups" do
    user = users(:joe)
    get :join, params: {id: groups(:three).id }
    assert_not user.in_group?(groups(:three))
  end

  test "signed in users can join secret groups they were invited to" do
    user = users(:viktor)
    sign_in user
    @request.env['HTTP_REFERER'] = '/groups'
    get :join, params: {id: groups(:four).id}
    assert user.in_group?(groups(:four))
  end

  test "signed in users can join public groups" do
    user = users(:joe)
    sign_in user
    @request.env['HTTP_REFERER'] = '/groups'
    get :join, params: {id: groups(:three).id }
    assert user.in_group?(groups(:three))
  end

  test "signed in users can leave group" do
    user = users(:viktor)
    sign_in user
    @request.env['HTTP_REFERER'] = '/groups'
    get :leave, params: {id: groups(:one).id }
    assert_not user.in_group?(groups(:three))
  end

  test "leaving group user is not in doesn't crash" do
    user = users(:joe)
    sign_in user
    @request.env['HTTP_REFERER'] = '/groups'
    get :leave, params: {id: groups(:three).id }
    assert_not user.in_group?(groups(:three))
  end
  
  test "user can change group privacy" do
    user = users(:joe)
    sign_in user
    post :update, params: { id: groups(:four).id, group: {privacy: :private_group} }
    groups(:four).reload
    assert_equal :private_group.to_s, groups(:four).privacy
    post :update, params: { id: groups(:four).id, group: { privacy: :secret_group } }
    groups(:four).reload
    assert_equal :secret_group.to_s, groups(:four).privacy
  end

  test "owner can change group name in group" do
    user = users(:moderatorMaven)
    sign_in user

    post :update, params: { id: groups(:publicGroup).id, group: {name:"newName"} }
    groups(:publicGroup).reload
    assert_equal "newName", groups(:publicGroup).name
    
    post :update, params: { id: groups(:privateGroup).id, group: {name:"newName"} }
    groups(:privateGroup).reload
    assert_equal "newName", groups(:privateGroup).name

    post :update, params: { id: groups(:secretGroup).id, group: {name:"newName"} }
    groups(:secretGroup).reload
    assert_equal "newName", groups(:secretGroup).name

    sign_out user
  end

  test "non-member cannot change group name in group" do
    user = users(:loserLarry)
    sign_in user

    post :update, params: { id: groups(:publicGroup).id, group: {name:"newName"} }
    groups(:publicGroup).reload
    assert_equal "public", groups(:publicGroup).name
    
    post :update, params: { id: groups(:privateGroup).id, group: {name:"newName"} }
    groups(:privateGroup).reload
    assert_equal "private", groups(:privateGroup).name

    post :update, params: { id: groups(:secretGroup).id, group: {name:"newName"} }
    groups(:secretGroup).reload
    assert_equal "secret", groups(:secretGroup).name

    sign_out user
  end

  test "member cannot change group name in group" do
    user = users(:memberMike)
    sign_in user

    post :update, params: { id: groups(:publicGroup).id, group: {name:"newName"} }
    groups(:publicGroup).reload
    assert_equal "public", groups(:publicGroup).name
    
    post :update, params: { id: groups(:privateGroup).id, group: {name:"newName"} }
    groups(:privateGroup).reload
    assert_equal "private", groups(:privateGroup).name

    post :update, params: { id: groups(:secretGroup).id, group: {name:"newName"} }
    groups(:secretGroup).reload
    assert_equal "secret", groups(:secretGroup).name

    sign_out user
  end

  test "moderator cannot change group name in group" do
    user = users(:moderatorMaven)
    sign_in user

    post :update, params: { id: groups(:publicGroup).id, group: {name:"newName"} }
    groups(:publicGroup).reload
    assert_equal "public", groups(:publicGroup).name
    
    post :update, params: { id: groups(:privateGroup).id, group: {name:"newName"} }
    groups(:privateGroup).reload
    assert_equal "private", groups(:privateGroup).name

    post :update, params: { id: groups(:secretGroup).id, group: {name:"newName"} }
    groups(:secretGroup).reload
    assert_equal "secret", groups(:secretGroup).name

    sign_out user
  end

end