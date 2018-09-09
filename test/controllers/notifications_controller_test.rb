require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def setup
    @viktor, @norm = users(:viktor, :norm)
  end

  test "read_all works" do
    @viktor.follow(@norm)
    sign_in @norm

    assert_equal 1, @norm.notifications.unread.count
    post :read
    assert_equal 0, @norm.notifications.unread.count
  end
end