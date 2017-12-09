require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "should get homepage when not signed in" do
    get :index
    assert_select "#home-sl1", true, "home should be rendered if not signed in"
  end

  test "should get dashboard when signed in" do
    sign_in users(:viktor)
    get :index
    assert_select "#greeting", true, "dashboard should be rendered if signed in"
  end
end
