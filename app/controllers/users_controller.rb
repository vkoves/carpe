class UsersController < ApplicationController
  before_filter :authorize_admin, only: [:index, :promote, :demote, :inspect] # authorize admin on the user viewing page
  before_action :authorize_signed_in, only: [:destroy]
  before_action :set_user, only: [:show]

  def index
    @users = User.all.sort_by(&:name) # fetch all users (including current, to see admin info)
    @admin_tiles = true
  end

  def show
    @profile = false
    @profile = true if current_user and current_user == @user # this is the user looking at their own profile

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

  # User search. Used to add users to stuff, like the sandbox user adder
  def search
    q = if params[:q]
          params[:q].strip
        else
          ""
        end

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
    @user = User.find params[:id]
    @user.update(admin: true)
    render json: { action: "promote", uid: @user.id, new_href: demote_user_path(@user)}
  end

  def demote
    @user = User.find params[:id]
    @user.update(admin: false)
    render json: { action: "demote", uid: @user.id, new_href: promote_user_path(@user)}
  end

  def destroy
    @user = User.find params[:id]

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
    @user = User.find params[:id]
    @user_groups = UsersGroup.where(user_id: @user.id)
  end

  private

  def set_user
    if params[:id] =~ User.REGEX_USER_ID
      @user = User.find params[:id]

      if @user.has_custom_url?
        vanity_params = params.merge(id: @user.custom_url).symbolize_keys
        redirect_to user_path(vanity_params), status: :moved_permanently
      end
    else
      @user = User.find_by! custom_url: params[:id]
    end
  end
end
