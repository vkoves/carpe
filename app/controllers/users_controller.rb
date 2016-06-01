class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by_id(params[:id]) #fetch the user by the URL passed id
    @profile = false
    if @user
      if current_user and current_user == @user #this is the user looking at their own profile
        @profile = true
      end

      case params[:p]
      when "friends"
        @tab = "friends"
      when "activity"
        @tab = "activity"
      when "mutual_friends"
        @tab = "mutual"
      when "schedule"
        @tab = "schedule"
      else #default, aka no params
        @tab = "schedule"
      end

      if params[:p] == "mutual_friends"
        @mutual_friends = current_user.mutual_friends(@user)
      else
        @all_friends = @user.all_friendships #and fetch all of the user's friends
      end
    else
      redirect_to "/404"
    end
  end

  def search
    if params[:q]
      q = params[:q].strip
    else
      q = ""
    end

    if q != "" #only search if it's not silly
      if request.path_parameters[:format] == 'json'
        @users = User.where('name LIKE ?', "%#{q}%").limit(10)
        @users = @users.sort {|a,b|
          a_rank = 0
          b_rank = 0

          a_rank = 2 if a.name.downcase.starts_with?(q.downcase) #if the users name starts with the query, it's a great match
          b_rank = 2 if b.name.downcase.starts_with?(q.downcase)

          a_rank = 1 if a.name.downcase.include?(" " + q.downcase) #if the users middle or last name start with the query, it's an okay match
          b_rank = 1 if b.name.downcase.include?(" " + q.downcase)

          b_rank <=> a_rank #return comparison of ranks, with highest preferred first
        } 
      else
        @users = User.where('name LIKE ?', "%#{q}%")
      end
    else
      @users = User.last(10)
    end

    respond_to do |format|
      format.html
      format.json {
        user_map = @users.map(&:attributes)
        user_map = user_map.map{|user|
          unless(User.find_by_id(user["id"]) and User.find_by_id(user["id"]).has_avatar) #if this is a valid user that has no avatar
            user[:image_url] = "http://www.gravatar.com/avatar/?d=mm" #change to the default avatar
          end
          user #and return the users
        }
        render :json => user_map
        #render :json => @users.map(&:attributes)
      }
    end
  end

  def find_friends
    if !current_user
      flash[:alert] = "You have to be signed in to find friends!"
      redirect_to "/users/sign_in"
    end

    if params[:q]
      q = params[:q].strip

      if q != "" #only search if it's not silly
        @users = User.where('name LIKE ?', "%#{q}%")
      end
    end
  end
end
