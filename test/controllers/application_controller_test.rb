require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "search route works" do
    get :search_core, q: "v"
    assert_response :success
  end
end