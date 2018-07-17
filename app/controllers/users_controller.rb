class UsersController < ApplicationController
  before_action :authorize_admin!, only: [:index, :promote, :demote, :inspect]
  before_action :authorize_signed_in!, only: [:destroy]


  def index
    @users = User.all.sort_by(&:name) # fetch all users (including current, to see admin info)
    @admin_tiles = true
  end

  def show
    @user = User.from_param(params[:id])

    # forces custom urls to be displayed (when applicable)
    if params[:id].is_int? and @user.has_custom_url?
      redirect_to user_path(@user), status: :moved_permanently
    end

    @profile = current_user == @user # this is the user looking at their profile

    case params[:page]
    when "followers"
      @tab = "followers"
    when "activity"
      @tab = "activity"
      @activity = @user.following_relationships + @user.followers_relationships
    when "mutual_friends"
      @tab = "mutual"
    when "schedule"
      @tab = "schedule"
    when "following"
      @tab = "following"
      @following = @user.following_relationships
    else # default, aka no params
      @tab = "schedule"
    end

    if @tab == "mutual"
      @mutual_friends = current_user.mutual_friends(@user)
    else
      @all_friends = @user.followers_relationships # and fetch all of the user's followers
    end
  end

  def promote
    @user = User.find(params[:id])
    @user.update(admin: true)
    render json: { action: "promote", uid: @user.id, new_href: demote_user_path(@user)}
  end

  def demote
    @user = User.find(params[:id])
    @user.update(admin: false)
    render json: { action: "demote", uid: @user.id, new_href: promote_user_path(@user)}
  end

  def destroy
    @user = User.from_param(params[:id])

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
    @user = User.find(params[:id])
    @user_groups = UsersGroup.where(user_id: @user.id)
  end
end
