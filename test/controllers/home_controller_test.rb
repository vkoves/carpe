require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  test "should get homepage when not signed in" do
    get :index
    assert_template("home/home", "home should be rendered if not signed in")
    assert_response :success
  end

  test "should get dashboard when signed in" do
    sign_in users(:viktor)
    get :index
    assert_template("home/dashboard", "dashboard should be rendered if signed in")
    assert_response :success
  end
end
