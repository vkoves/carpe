class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

	protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  def authorize_admin
  	unless current_user and current_user.admin
  		# flash[:alert] = "Unauthorized access"
  		redirect_to home_path
  		return false
  	end
  end

  def authorize_signed_in
    unless current_user
      flash[:alert] = "You have to be signed in to do that!"
      redirect_to user_session_path
      return false
    end
  end
end
