require 'test_helper'

class ScheduleControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "signed in users can delete their event" do
    sign_in users(:norm)
    get :delete_event, params: { id: 101 }
    assert_response :success
  end
end