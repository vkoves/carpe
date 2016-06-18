require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  #Admin Page Security Tests
  test "should not get admin if not signed in" do
    get :admin
    assert_response :redirect
  end

  test "should not be able to go to admin if user is not admin" do
  	sign_in users(:norm)
  	get :admin
  	assert_response :redirect
  end

  test "should be able to go to admin if user is admin" do
  	sign_in users(:viktor)
  	get :admin
  	assert_response :success
  end

  #Sandbox Page Security Tests
  test "should not get sandbox if not signed in" do
  	get :sandbox
  	assert_response :redirect
  end

  test "should not be able to go to sandbox if user is not admin" do
  	sign_in users(:norm)
  	get :sandbox
  	assert_response :redirect
  end

  test "should be able to go to sandbox if user is admin" do
  	sign_in users(:viktor)
  	get :sandbox
  	assert_response :success
  end
end
