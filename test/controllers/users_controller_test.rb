# To run all tests, in the project directory run the command:
# bundle exec rails test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rails test test/controllers/users_controller_test.rb

require "test_helper"

class UsersControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def setup
    @viktor, @norm, @putin = users(:viktor, :norm, :putin)
  end

  test "should route to user" do # test if the users route is working properly
    assert_routing "/users/1", controller: "users", action: "show", id: "1"
  end

  test "signed in user should be able to view other user" do
    sign_in @viktor
    get :show, params: { id: @norm }
    assert_response :success
  end

  test "non-signed in user should be able to view user" do
    get :show, params: { id: @norm }
    assert_response :success
  end

  test "user views can be accessed through their custom urls" do
    get :show, params: { id: @putin.custom_url }
    assert_response :success
  end

  test "the user path of users with a custom url should be their custom url" do
    assert_match(/.*viktor/, user_path(@viktor))
  end

  test "the user path of users without a custom url should be their user id" do
    assert_match(/.*2/, user_path(@norm))
  end

  test "routes to a user's id should redirect to their custom url when present" do
    get :show, params: { id: @viktor }
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
    assert_select ".profile-header"
  end

  test "users can navigate to the schedule tab" do
    get :show, params: { id: @norm, page: "schedule" }
    assert_response :success
  end

  test "users can navigate to the followers tab" do
    get :show, params: { id: @norm, page: "followers" }
    assert_response :success
  end

  test "users can navigate to the following tab" do
    get :show, params: { id: @norm, page: "following" }
    assert_response :success
  end

  test "users can navigate to the activity tab" do
    get :show, params: { id: @norm, page: "activity" }
    assert_response :success
  end

  test "users will navigate to the schedule tab by default" do
    get :show, params: { id: @norm }
    assert_response :success
  end

  test "trying to view users that do not exist should redirect to the 404 page" do
    get :show, params: { id: "01010101010101" }
    assert_response :missing
  end

  test "admins (or the account owner) can delete users" do
    sign_in @viktor
    assert_difference "User.count", -1 do
      delete :destroy, params: { id: @norm }
    end
  end

  test "users cannot delete other users" do
    sign_in @norm
    assert_no_difference "User.count" do
      delete :destroy, params: { id: @viktor }
    end
  end

  test "admins can promote users" do
    sign_in @viktor
    get :promote, params: { id: @putin }
    assert User.find(@putin.id).admin, "admin was unable to promote user"
  end

  test "users cannot promote other users" do
    sign_in @norm
    get :promote, params: { id: @putin }
    assert_not User.find(@putin.id).admin, "non-admin successfully promoted a user"
  end

  test "admins can view detailed user information" do
    sign_in @viktor
    get :inspect, params: { id: @norm }
    assert_response :success
  end

  test "users cannot view detailed user information" do
    sign_in @norm
    get :inspect, params: { id: @viktor }
    assert_response :redirect
  end

  test "categories hides private category details from other user" do
    private_cat = categories(:private)

    sign_in @norm

    get :categories, params: { id: @viktor }

    resp_json = JSON.parse(response.body)
    resp_category = resp_json.find { |c| c["id"] == private_cat.id }

    # Ensure the returned cateogry name is NOT the real name
    assert_not_equal resp_category["name"], private_cat.name
  end

  test "categories shows private category details to owner" do
    private_cat = categories(:private)

    sign_in @viktor

    get :categories, params: { id: @viktor }

    resp_json = JSON.parse(response.body)
    resp_category = resp_json.find { |c| c["id"] == private_cat.id }

    # Ensure the returned cateogry name IS the real name
    assert_equal resp_category["name"], private_cat.name
  end

  test "events action hides private event from other user" do
    private_event = events(:private)

    sign_in @norm

    get :events, params: { id: @viktor }

    resp_json = JSON.parse(response.body)
    resp_event = resp_json.find { |e| e["id"] == private_event.id }

    # Ensure we couldn't find the event with that ID
    assert_nil resp_event
  end

  test "events action show private event details to owner" do
    private_event = events(:private)

    sign_in @viktor

    get :events, params: { id: @viktor }

    resp_json = JSON.parse(response.body)
    resp_event = resp_json.find { |e| e["id"] == private_event.id }

    # Ensure the returned name is real name, confirming we got the event
    assert_equal resp_event["name"], private_event.name
  end
end
