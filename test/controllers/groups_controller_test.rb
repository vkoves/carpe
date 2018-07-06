require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  # called before every test
  def setup
    @request.env['HTTP_REFERER'] = '/groups'
  end
  
  # create
  test "user must be signed in to create a group" do
    get :create
    assert_response :redirect
  end

  test "signed in users can create a group" do
    sign_in users(:loserLarry)
    assert_difference 'Group.count', +1 do
      get :create, params: { group: { name: "Test Group" } }
    end
  end

  # read

  test "user must be signed in to see groups" do
    get :index
    assert_response :redirect
  end

  test "signed in users can see groups" do
    sign_in users(:loserLarry)
    get :index
    assert_response :success
  end

  test "user cannot see public group when not signed in" do
    get :show, params: {id:groups(:publicGroup).id}
    assert_response :redirect
  end

  test "signed in users can see a public group" do
    sign_in users(:loserLarry)
    get :show, params: {id:groups(:publicGroup).id}
    assert_response :success
  end

  test "user cannot see private group when not signed in" do
    get :show, params: {id:groups(:privateGroup).id}
    assert_response :redirect
  end

  test "signed in users can see a private group" do
    sign_in users(:loserLarry)
    get :show, params: {id:groups(:privateGroup).id}
    assert_response :success
  end

  test "user cannot see secret group when not signed in" do
    get :show, params: {id:groups(:secretGroup).id}
    assert_response :redirect
  end

  test "signed in users not in secret group cannot see it" do
    sign_in users(:loserLarry)
    get :show, params: {id:groups(:secretGroup).id}
    assert_response :redirect
  end

  test "signed in users in secret group can see it" do
    sign_in users(:memberMike)
    get :show, params: {id:groups(:secretGroup).id}
    assert_response :success
  end
  
  # update

  test "owner can change group name in group" do
    user = users(:ownerAlice)
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

  test "any signed in user can join public groups" do
    user = users(:loserLarry)
    sign_in user
    get :join, params: {id: groups(:publicGroup).id }
    assert user.in_group?(groups(:publicGroup))
  end

  test "signed in users cannot join private groups they were not invited to" do
    user = users(:loserLarry)
    sign_in user
    get :join, params: {id: groups(:privateGroup).id }
    assert_not user.in_group?(groups(:privateGroup))
  end

  test "signed in users can join private groups they were invited to" do
    user = users(:inviteIvan)
    sign_in user
    get :join, params: {id: groups(:privateGroup).id }
    assert user.in_group?(groups(:privateGroup))
  end

  test "signed in users cannot join secret groups they were not invited to" do
    user = users(:loserLarry)
    sign_in user
    get :join, params: {id: groups(:secretGroup).id }
    assert_not user.in_group?(groups(:secretGroup))
  end

  test "signed in users can join secret groups they were invited to" do
    user = users(:inviteIvan)
    sign_in user
    get :join, params: {id: groups(:secretGroup).id }
    assert user.in_group?(groups(:secretGroup))
  end

  test "signed in users can leave public group" do
    user = users(:memberMike)
    sign_in user
    get :leave, params: {id: groups(:publicGroup).id }
    assert_not user.in_group?(groups(:publicGroup))
  end

  test "signed in users can leave private group" do
    user = users(:memberMike)
    sign_in user
    get :leave, params: {id: groups(:privateGroup).id }
    assert_not user.in_group?(groups(:privateGroup))
  end

  test "signed in users can leave secret group" do
    user = users(:memberMike)
    sign_in user
    get :leave, params: {id: groups(:secretGroup).id }
    assert_not user.in_group?(groups(:secretGroup))
  end

  test "leaving public group user is not in doesn't crash" do
    user = users(:loserLarry)
    sign_in user
    get :leave, params: {id: groups(:publicGroup).id }
    assert_not user.in_group?(groups(:publicGroup))
  end

  test "leaving private group user is not in doesn't crash" do
    user = users(:loserLarry)
    sign_in user
    get :leave, params: {id: groups(:privateGroup).id }
    assert_not user.in_group?(groups(:privateGroup))
  end

  test "leaving secret group user is not in doesn't crash" do
    user = users(:loserLarry)
    sign_in user
    get :leave, params: {id: groups(:secretGroup).id }
    assert_not user.in_group?(groups(:secretGroup))
  end

  test "not signed in users can not join public groups" do
    get :join, params: {id: groups(:publicGroup).id }
    assert_not users(:inviteIvan).in_group?(groups(:publicGroup))
  end

  test "not signed in users can not join private groups" do
    get :join, params: {id: groups(:privateGroup).id }
    assert_not users(:inviteIvan).in_group?(groups(:privateGroup))
  end

  test "not signed in users can not join secret groups" do
    get :join, params: {id: groups(:secretGroup).id }
    assert_not users(:inviteIvan).in_group?(groups(:secretGroup))
  end

  # delete

  test "owner can delete group" do
    user = users(:ownerAlice)
    sign_in user

    groups(:publicGroup, :privateGroup, :secretGroup).each do |group|
      assert_difference ->{ Group.count }, -1 do
        delete :destroy, params: {id: group.id }
      end
    end
  end

  test "moderator cannot delete group" do
    user = users(:moderatorMaven)
    sign_in user

    groups(:publicGroup, :privateGroup, :secretGroup).each do |group|
      assert_no_difference ->{ Group.count } do
        delete :destroy, params: { id: group.id }
      end
    end
  end

  test "memeber cannot delete group" do
    user = users(:memberMike)
    sign_in user

    groups(:publicGroup, :privateGroup, :secretGroup).each do |group|
      assert_no_difference ->{ Group.count } do
        delete :destroy, params: { id: group.id }
      end
    end
  end

  test "non-member cannot delete group" do
    user = users(:loserLarry)
    sign_in user

    groups(:publicGroup, :privateGroup, :secretGroup).each do |group|
      assert_no_difference ->{ Group.count } do
        delete :destroy, params: { id: group.id }
      end
    end
  end
end
