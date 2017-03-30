# To run all tests, in the project directory run the command:
# bundle exec rake test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rake test test/controllers/users_controller_test.rb

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  test "should route to user" do #test if the users route is working properly
    assert_routing '/u/1', { controller: "users", action: "show", id_or_url: "1" }
  end

  test "signed in user should be able to view other user" do
  	sign_in users(:viktor)
  	get :show, id_or_url: users(:norm).id
  	assert_response :success
  end

  test "non-signed in user should be able to view user" do
  	get :show, id_or_url: users(:norm).id
  	assert_response :success
  end

  test "the user path of users with a custom url should be their custom url" do
    assert_match /.*viktor/, user_path(users(:viktor))
  end

  test "the user path of users without a custom url should be their user id" do
    assert_match /.*2/, user_path(users(:norm))
  end

  test "routes leading to a user's id should redirect to their custom url when present" do
    get :show, id_or_url: users(:viktor).id
    assert_redirected_to user_path(users(:viktor))
  end
end
