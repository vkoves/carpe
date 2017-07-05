# To run all tests, in the project directory run the command:
# bundle exec rake test
# ----------------------------------------
# To run this test, in the project directory run the command:
# bundle exec rake test test/controllers/pages_controller_test.rb

require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def setup
    @viktor, @norm, @putin = users(:viktor, :norm, :putin)
  end

  #Admin Page Security Tests
  test "should not get admin if not signed in" do
    get :admin
    assert_response :redirect
  end

  test "should not be able to go to admin if user is not admin" do
  	sign_in @norm
  	get :admin
  	assert_response :redirect
  end

  test "should be able to go to admin if user is admin" do
  	sign_in @viktor
  	get :admin
  	assert_response :success
  end

  #Sandbox Page Security Tests
  test "should not get sandbox if not signed in" do
  	get :sandbox
  	assert_response :redirect
  end

  test "should not be able to go to sandbox if user is not admin" do
  	sign_in @norm
  	get :sandbox
  	assert_response :redirect
  end

  test "should be able to go to sandbox if user is admin" do
  	sign_in @viktor
  	get :sandbox
  	assert_response :success
  end

  test "only admins can delete users" do
    sign_in @norm
    assert_difference 'User.count', 0 do
      delete :destroy_user, id: @viktor.id
    end

    sign_out @norm

    sign_in @viktor
    assert_difference 'User.count', -1 do
      delete :destroy_user, id: @norm.id
    end
  end

  test "only admins can promote/demote users" do
    sign_in @norm
    get :promote, id: @putin.id, de: false
    assert_not User.find(@putin.id).admin, "non-admin successfully promoted a user"

    sign_out @norm

    sign_in @viktor
    get :promote, id: @putin.id, de: false
    assert User.find(@putin.id).admin, "admin was unable to promote user"
  end

  test "admins can view user information" do
    sign_in @viktor
    get :admin_user_info, id: @norm.id
    assert_response :success
  end
end
