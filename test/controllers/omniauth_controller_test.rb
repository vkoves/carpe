require "test_helper"

class OmniauthCallbacksControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def setup
    mock = {
      provider: "google_oauth2",
      uid: "12345",
      info: {
        name: "fake",
        email: "fake@yahoo.com"
      }
    }

    OmniAuth.config.test_mode = true
    request.env["devise.mapping"] = Devise.mappings[:user]

    OmniAuth.config.add_mock(:valid_google_user, mock)

    mock[:info][:email] = users(:viktor).email
    OmniAuth.config.add_mock(:existung_user, mock)

    OmniAuth.config.add_mock(:invalid_google_user, provider: "google_oauth2")

    # set the default mockup to use
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:valid_google_user]
  end

  test "should create a new user for new google sign ins" do
    assert_difference "User.count", +1 do
      get :google_oauth2
    end

    assert_response :redirect
  end

  test "should not create new user for existing user" do
    get :google_oauth2

    assert_no_difference "User.count" do
      get :google_oauth2
    end
  end

  test "should find already registered users by email" do
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:existung_user]

    assert_no_difference "User.count" do
      get :google_oauth2
    end
  end

  test "failed omniauth request should redirect to registration page" do
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:invalid_google_user]
    get :google_oauth2
    assert_redirected_to new_user_registration_url
  end
end
