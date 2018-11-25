require 'test_helper'

class EventInvitesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "duplicate event invites are rejected" do
    sign_in users(:viktor)

    # existing event invite
    event_invite = event_invites(:putin_music)
    event = event_invite.event
    user = event_invite.user

    assert_no_difference -> { EventInvite.count } do
      post event_invites_path(event, user_ids: [user.id])
    end
  end
end
