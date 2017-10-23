class UsersController < ApplicationController
  before_action  :authorize_admin, :only => [:index] #authorize admin on the user viewing page


  def index
    @users = User.all.sort_by(&:name) # fetch all users (including current, to see admin info)
    @admin_tiles = true
  end

  def show
    using_id = (params[:id_or_url] =~ /\A[0-9]+\Z/)
    if using_id
      @user = User.find_by(id: params[:id_or_url]) or not_found
      redirect_to user_path(@user) if @user.has_custom_url?
    else
      @user = User.find_by(custom_url: params[:id_or_url])  or not_found
    end

    @profile = false
    if current_user and current_user == @user #this is the user looking at their own profile
      @profile = true
    end

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
    else #default, aka no params
      @tab = "schedule"
    end

    if @tab == "mutual"
      @mutual_friends = current_user.mutual_friends(@user)
    else
      @all_friends = @user.followers_relationships #and fetch all of the user's followers
    end
  end

  #User search. Used to add users to stuff, like the sandbox user adder
  def search
    if params[:q]
      q = params[:q].strip
    else
      q = ""
    end

    if q != "" #only search if it's not silly
      if request.path_parameters[:format] == 'json'
        @users = User.where('name LIKE ?', "%#{q}%").limit(10)
        @users = User.rank(@users, q)
      else
        @users = User.where('name LIKE ?', "%#{q}%")
      end
    end

    respond_to do |format|
      format.html
      format.json {
        # Return the users in their public JSON form
        user_map = @users.map(&:convert_to_json)
        
        render :json => user_map
      }
    end
  end
end
