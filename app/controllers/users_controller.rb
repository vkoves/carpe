class UsersController < ApplicationController
  before_action :authorize_admin, only: [:index]
  before_action :set_user, only: [:show]

  def index
    @users = User.all.sort_by(&:name)
    @admin_tiles = true
  end

  def show
    # is this a user looking at their own profile?
    @profile = current_user == @user

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

    if request.path_parameters[:format] == 'json'
      @users = User.where('name LIKE ?', "%#{q}%").limit(10)
      @users = User.rank(@users, q)
    else
      @users = User.where('name LIKE ?', "%#{q}%")
    end

    respond_to do |format|
      format.html
      format.json do
        user_map = @users.map(&:convert_to_json)
        render json: user_map
      end
    end
  end

  private

  def set_user
    if params[:id_or_url] =~ User.REGEX_USER_ID
      @user = User.find_by! id: params[:id_or_url]
      redirect_to user_path(@user) if @user.has_custom_url?
    else
      @user = User.find_by! custom_url: params[:id_or_url]
    end
  end
end
