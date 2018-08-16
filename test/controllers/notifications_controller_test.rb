require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @viktor, @norm = users(:viktor, :norm)
  end

  test "read_all works" do
    @viktor.follow(@norm)
    sign_in @norm

    assert_equal 1, @norm.notifications.unread.count
    post read_notifications_path
    assert_equal 0, @norm.notifications.unread.count
  end

  test "followed user gets notified when someone follows them" do
    @viktor.follow(@norm)

    sign_in @norm
    get root_path
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
    get root_path
    assert_select ".notif div", text: "Hey you! Yeah you!"
  end

  test "users can join groups that they were invited to" do
    invited_user = users(:loserLarry)
    group = groups(:publicGroup)
    # groups = groups(:publicGroup, :privateGroup, :secretGroup)

    sign_in group.owner
    post group_invite_path(group_id: group.id, user_id: invited_user.id)
    sign_out group.owner

    sign_in invited_user
    group_invite = invited_user.notifications.group_invite.first
    post update_notification_path(group_invite, "accepted")

    assert invited_user.in_group?(group)
    sign_out invited_user
  end
end