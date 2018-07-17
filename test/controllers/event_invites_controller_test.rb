require 'test_helper'

class EventInvitesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @invite = event_invites(:one)
  end

  test "should get index" do
    sign_in users(:viktor)
    get event_invites_url
    assert_response :success
  end

  test "should create event_invite" do
    sign_in users(:viktor)

    assert_difference -> { EventInvite.count }, +1 do
      post event_invites_url, params: {
        event_id: events(:simple).id, recipient_id: users(:putin).id, role: "guest"
      }
    end

    assert_response :success
  end

  test "should update event_invite" do
    sign_in users(:viktor)
    patch event_invite_url(@invite), params: { event_invite: { role: "host" } }
    @invite.reload

    assert_equal "host", @invite.role
  end

  test "should destroy event_invite" do
    sign_in users(:viktor)
    assert_difference -> { EventInvite.count }, -1 do
      delete event_invite_url(@invite)
    end
  end
end
