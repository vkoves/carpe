require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @viktor, @norm = users(:viktor, :norm)
  end

  test "followed user gets notified when someone follows them" do
    @viktor.follow(@norm)

    sign_in @norm
    get "/home"
    assert_select "#num", count: 1, text: "1"
  end

  test "accepting a follow requests work" do
    sign_in @norm

    @norm.unfollow(@viktor)

    # norm follows viktor
    assert_difference -> { @viktor.notifications.count }, +1 do
      post relationships_path(followed_id: @viktor.id)
    end

    assert_not @norm.following?(@viktor)

    # viktor accepts follow request
    assert_difference -> { @viktor.notifications.count }, -1 do
      post update_notification_path(@viktor.notifications.last, "confirm")
    end

    assert @norm.following?(@viktor)
  end

  test "declining a follow request works" do
    sign_in @norm
    @norm.unfollow(@viktor)

    post relationships_path(followed_id: @viktor.id)

    assert_not @norm.following?(@viktor)

    # viktor denies follow request
    assert_difference -> { @viktor.notifications.count }, -1 do
      post update_notification_path(@viktor.notifications.last, "deny")
    end

    assert_not @norm.following?(@viktor)
  end

  test "general purpose messages get rendered" do
    Notification.create!(
      receiver: @norm,
      event: :system_message,
      message: "Hey you! Yeah you!"
    )

    sign_in @norm
    get "/home"
    assert_select ".notif div", text: "Hey you! Yeah you!"
  end

  test "users can join groups that they were invited to" do
    invited_user = users(:loserLarry)
    groups = groups(:publicGroup, :privateGroup, :secretGroup)

    groups.each do |group|
      sign_in group.owner
        post invite_to_group_path(group_id: group.id, user_id: invited_user.id)
      sign_out group.owner

      sign_in invited_user
        group_invite = invited_user.notifications.group_invite.first
        post update_notification_path(group_invite, "accepted")

        assert invited_user.in_group?(group)
      sign_out invited_user
    end
  end

  test "users can invite other users to their event" do
    sign_in @viktor

    assert_difference -> { @norm.notifications.count }, +1 do
      post event_invites_path(events(:simple), user_ids: [@norm.id])
    end

    assert @norm.invited_to_event?(events(:simple))
  end

  test "users can accept event invites" do
    sign_in @viktor
    post event_invites_path(events(:simple), user_ids: [@norm.id])

    sign_in @norm
    post update_notification_path(@norm.notifications.last, "accepted")

    assert @norm.attending_event?(events(:simple))
  end

  test "users can respond 'maybe' to event invite" do
    sign_in @viktor
    post event_invites_path(events(:simple), user_ids: [@norm.id])

    sign_in @norm
    post update_notification_path(@norm.notifications.last, "maybe")

    assert @norm.attending_event?(events(:simple))
  end

  test "users can decline event invites" do
    sign_in @viktor
    post event_invites_path(events(:simple), user_ids: [@norm.id])

    sign_in @norm
    post update_notification_path(@norm.notifications.last, "declined")

    assert_not @norm.attending_event?(events(:simple))
  end
end