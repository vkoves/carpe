# To run all tests, in the project directory run the command:
# bundle exec rails test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rails test test/controllers/users_controller_test.rb

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def setup
    @viktor, @norm, @putin = users(:viktor, :norm, :putin)
  end

  test "should route to user" do # test if the users route is working properly
    assert_routing '/users/1', controller: "users", action: "show", id: "1"
  end

  test "signed in user should be able to view other user" do
    sign_in @viktor
    get :show, params: { id: @norm.id }
    assert_response :success
  end

  test "non-signed in user should be able to view user" do
    get :show, params: { id: @norm.id }
    assert_response :success
  end

  test "user views can be accessed through their custom urls" do
    get :show, params: { id: @putin.custom_url }
    assert_response :success
  end

  test "the user path of users with a custom url should be their custom url" do
    assert_match /.*viktor/, user_path(@viktor)
  end

  test "the user path of users without a custom url should be their user id" do
    assert_match /.*2/, user_path(@norm)
  end

  test "routes to a user's id should redirect to their custom url when present" do
    get :show, params: { id: @viktor.id }
    assert_redirected_to user_path(@viktor)
  end

  test "should not be able to go to users panel if user is not an admin" do
    sign_in @norm
    get :index
    assert_redirected_to home_path
  end

  test "should be able to go to users panel if user is an admin" do
    sign_in @viktor
    get :index
    assert_response :success
  end

  test "signed in users can view their own profile" do
    sign_in @viktor
    get :show, params: { id: @viktor.custom_url }
    assert_select "div#profile-header"
  end

  test "users can navigate to the schedule tab" do
    get :show, params: { id: @norm.id, page: "schedule" }
    assert_response :success
  end

  test "users can navigate to the followers tab" do
    get :show, params: { id: @norm.id, page: "followers" }
    assert_response :success
  end

  test "users can navigate to the following tab" do
    get :show, params: { id: @norm.id, page: "following" }
    assert_response :success
  end

  test "users can navigate to the activity tab" do
    get :show, params: { id: @norm.id, page: "activity" }
    assert_response :success
  end

  # mutual_friends not fully implemented yet
  # test "users can navigate to the mutual friends tab" do
  #   get :show, id: @norm.id, page: 'mutual_friends'
  #   assert_response :success
  # end

  test "users will navigate to the schedule tab by default" do
    get :show, params: { id: @norm.id }
    assert_response :success
  end

  test "trying to view users that do not exist should redirect to the 404 page" do
    get :show, params: { id: "01010101010101" }
    assert_response :missing
  end

  test "only admins (or the account owner) can delete users" do
    sign_in @norm
    assert_no_difference 'User.count' do
      delete :destroy, params: { id: @viktor.id }
    end

    sign_out @norm

    sign_in @viktor
    assert_difference 'User.count', -1 do
      delete :destroy, params: { id: @norm.id }
    end
  end

  test "only admins can promote users" do
    sign_in @norm
    get :promote, params: { id: @putin.id }
    assert_not User.find(@putin.id).admin, "non-admin successfully promoted a user"

    sign_out @norm

    sign_in @viktor
    get :promote, params: { id: @putin.id }
    assert User.find(@putin.id).admin, "admin was unable to promote user"
  end

  test "only admins can view user information" do
    sign_in @norm

    get :inspect, params: { id: @viktor.id }
    assert_response :redirect

    sign_out @norm
    sign_in @viktor

    # user without custom url
    get :inspect, params: { id: @norm.id }
    assert_response :success

    # user with custom url
    get :inspect, params: { id: @viktor.id }
    assert_response :success
  end
end
