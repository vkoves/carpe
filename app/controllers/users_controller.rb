class UsersController < ApplicationController
  before_action :authorize_admin!, only: [:index, :promote, :demote, :inspect]
  before_action :authorize_signed_in!, only: [:destroy]

  def index
    @users = User.all.sort_by(&:name)
    @admin_tiles = true
  end

  def show

    @user = User.from_param(params[:id])

    # is this a user looking at their own profile?
    @profile = current_user == @user

    # forces custom urls to be displayed (when applicable)
    if params[:id].is_int? and @user.has_custom_url?
      redirect_to user_path(@user), status: :moved_permanently
    end


    @current_page = params[:page]&.to_sym || :schedule
    case @current_page
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

  # User search. Used to add users to stuff, like the sandbox user adder
  def search
    q = params[:q]&.strip
    return unless q.present?

    if q != "" # only search if it's not silly
      if request.path_parameters[:format] == 'json'
        @users = User.where('name LIKE ?', "%#{q}%").limit(10)
        @users = User.rank(@users, q)
      else
        @users = User.where('name LIKE ?', "%#{q}%")
      end
    end

    respond_to do |format|
      format.html
      format.json do
        # Return the users in their public JSON form
        user_map = @users.map(&:convert_to_json)

        render json: user_map
      end
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
