require "test_helper"

class EventInvitesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @invite = event_invites(:repeat_daily)
  end

  test "duplicate event invites are rejected" do
    sign_in users(:viktor)

    # existing event invite
    event_invite = event_invites(:putin_music)
    event = event_invite.host_event
    user = event_invite.user

    assert_no_difference -> { EventInvite.count } do
      post event_invites_path(event, user_ids: [user.id])
    end
  end

  test "email action updates status from pending to accepted" do
    assert_equal @invite.status, "pending_response"

    get event_invite_email_action_path(id: @invite.id, new_status: "accepted", token: @invite.token)

    # Re-fetch invite and check status
    assert_equal EventInvite.find(@invite.id).status, "accepted"
    assert_redirected_to home_path
    assert_match(/have updated that event invite/, flash[:notice])
  end

  test "email action fails without token" do
    assert_equal @invite.status, "pending_response"

    get event_invite_email_action_path(id: @invite.id, new_status: "accepted")

    # Re-fetch invite and check status
    assert_equal EventInvite.find(@invite.id).status, "pending_response"
    assert_redirected_to home_path
    assert_match(/You don't have permission/, flash[:alert])
  end

  test "event owner can invite guests" do
    sign_in users(:viktor)
    event = events(:music_convention)
    user = users(:ownerAlice)

    assert_difference -> { EventInvite.count }, +1 do
      post event_invites_path(event, user_ids: [user.id])
    end
  end

  test "event owner can remove guest" do
    sign_in users(:viktor)
    delete event_invite_path(event_invites(:joe_music))
    assert_response :success
  end

  test "only the event owner can remove guests" do
    sign_in users(:putin)
    delete event_invite_path(event_invites(:joe_music))
    assert_response :unauthorized
  end

  test "only the event owner can invite people" do
    sign_in users(:putin)
    event = events(:music_convention)
    user = users(:ownerAlice)

    post event_invites_path(event, user_ids: [user.id])
    assert_response :unauthorized
  end
end
