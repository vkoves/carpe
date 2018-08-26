require 'overridden_helpers'

class ApplicationController < ActionController::Base
  include OverriddenHelpers

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Enable rack-mini-profiler for signed in admin
  before_action do
    if current_user && current_user.admin
      if Rails.env.production?
        Rack::MiniProfiler.config.start_hidden = true # hide profiler by default on production (Alt+P to show)
      end

      unless Rails.env.test?
        Rack::MiniProfiler.authorize_request
      end
    end
  end

  # rather than catching exceptions in the actions, do it here.
  rescue_from ActiveRecord::RecordNotFound, with: :render_404 unless Rails.env.development?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to request.referrer || home_path, alert: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  def not_found
    raise ActiveRecord::RecordNotFound, 'Not Found'
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
    unless current_user&.admin
      redirect_to home_path
    end
  end

  # Authorize if a user is signed in
  def authorize_signed_in!
    unless current_user
      redirect_to user_session_path, alert: "You have to be signed in to do that!"
    end
  end
end
