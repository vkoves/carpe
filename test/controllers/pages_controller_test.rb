require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should not get admin if not signed in" do
    get :admin
    assert_response :redirect
  end

end
