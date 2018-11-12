require "overridden_helpers"

class ApplicationController < ActionController::Base
  include OverriddenHelpers

  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :set_time_zone, if: :current_user

  # Enable rack-mini-profiler for signed in admin
  before_action do
    if current_user&.admin
      if Rails.env.production?
        Rack::MiniProfiler.config.start_hidden = true # hide profiler by default on production (Alt+P to show)
      end

      Rack::MiniProfiler.authorize_request unless Rails.env.test?
    end
  end

  # rather than catching exceptions in the actions, do it here.
  rescue_from ActiveRecord::RecordNotFound, with: :render_404 unless Rails.env.development?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: "text/html" }
      format.html { redirect_to request.referrer || home_path, alert: exception.message }
      format.js   { head :forbidden, content_type: "text/html" }
    end
  end

  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  def not_found
    raise ActiveRecord::RecordNotFound, "Not Found"
  end

  # convenience method for controller actions using scrolling pagination
  def paginate(collection, partial)
    if params[:page].present?
      render partial: partial, collection: collection
    else
      render action_name
    end
  end

  protected

  # Allow sign up and edit profile to take the name parameter. Needed by devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # Authorize if a user is signed in and is admin before viewing a pge
  def authorize_admin!
    redirect_to home_path unless current_user&.admin
  end

  # Authorize if a user is signed in
  def authorize_signed_in!
    redirect_to user_session_path, alert: "You have to be signed in to do that!" unless current_user
  end

  private

  def set_time_zone
    Time.use_zone(current_user.home_time_zone) { yield }
  end
end
