class UsersController < ApplicationController
  before_action :authorize_admin!, only: [:index, :promote, :demote, :inspect]
  before_action :authorize_signed_in!, only: [:destroy]

  # Get a User via params[:id] and assign to @user unless viewing multiple users
  before_action :get_user, except: [:index]

  def index
    @users = User.all.sort_by(&:name)
    @admin_tiles = true
  end

  def show
    # is this a user looking at their own profile?
    @profile = current_user == @user

    # forces custom urls to be displayed (when applicable)
    redirect_to user_path(@user), status: :moved_permanently if params[:id].is_int? && @user.has_custom_url?

    @view = params[:page]&.to_sym || :schedule
    case @view
    when :activity
      @page_view = "activity"
      @activity = @user.following_relationships + @user.followers_relationships
    when :followers
      @page_view = "follower_listing"
      @all_friends = @user.followers_relationships
    when :following
      @page_view = "following_listing"
      @following = @user.following_relationships
    when :mutual
      @page_view = "mutual_friends_listing"
      @mutual_friends = current_user.mutual_friends(@user)
    when :schedule
      @page_view = "schedule"
    end
  end

  def promote
    @user.update(admin: true)
    render json: { action: "promote", uid: @user.id, new_href: demote_user_path(@user) }
  end

  def demote
    @user.update(admin: false)
    render json: { action: "demote", uid: @user.id, new_href: promote_user_path(@user) }
  end

  # Returns the user's categories as JSON for FE JS, making sure to only show
  # categories the current_user can access
  def categories
    render json: @user.categories_accessible_by(current_user).to_json
  end

  # Returns the user's events as JSON for FE JS, making sure to only show events
  # the current_user can access
  def events
    render json: @user.events_accessible_by(current_user)
  end

  def destroy
    if current_user.admin
      @user.destroy
      redirect_to admin_panel_path, notice: "User deleted"
    elsif current_user == @user
      @user.destroy
      redirect_to home_path, notice: "Account deleted"
    else
      redirect_to user_session_path, alert: "You don't have permission to do that!"
    end
  end

  def inspect
    @user_groups = UsersGroup.where(user_id: @user.id)
  end

  protected

  def get_user
    @user = User.from_param(params[:id])
  end
end
