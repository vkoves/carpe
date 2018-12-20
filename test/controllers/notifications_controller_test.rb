require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @viktor, @norm = users(:viktor, :norm)
  end

  test "read_all works" do
    sign_in @viktor
    post relationships_path(followed_id: @norm.id)
    sign_out @viktor

    sign_in @norm

    assert_not_empty @norm.notifications.unread
    post read_notifications_path
    assert_empty @norm.notifications.unread
  end
end
