require 'test_helper'

class NotificationsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @viktor, @norm = users(:viktor, :norm)
  end

  test "Followed user gets notified when someone follows them" do
    @viktor.follow(@norm)

    sign_in @norm
    get "/home"
    assert_select "#num", count: 1, text: "1"
  end

  test "friend requests work" do
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
end