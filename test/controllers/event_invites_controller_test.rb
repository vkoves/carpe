require 'test_helper'

class EventInvitesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @invite = event_invites(:simple)
  end

  test "email action updates status from pending to accepted" do
    assert_equal @invite.status, 'pending_response'

    get event_invite_email_action_path(id: @invite.id, new_status: 'accepted')

    # Re-fetch invite and check status
    assert_equal EventInvite.find(@invite.id).status, 'accepted'
    assert_redirected_to home_path
    assert_match /have updated that event invite/, flash[:notice]
  end
end
