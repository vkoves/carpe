# To run all tests, in the project directory run the command:
# bundle exec rake test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rake test test/controllers/users_controller_test.rb

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "should route to user" do #test if the users route is working properly
    assert_routing '/u/1', { controller: "users", action: "show", id: "1" }
  end

  test "signed in user should be able to view other user" do
  	sign_in users(:viktor)
  	get :show, id: users(:norm).id
  	assert_response :success
  end

  test "non-signed in user should be able to view user" do
  	get :show, id: users(:norm).id
  	assert_response :success
  end
end
