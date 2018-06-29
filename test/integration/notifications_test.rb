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
      post notification_updated_path(@viktor.notifications.last, "confirm")
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
      post notification_updated_path(@viktor.notifications.last, "deny")
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
    assert_select ".notif", text: "Hey you! Yeah you!"
  end
end