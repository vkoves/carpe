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
end
