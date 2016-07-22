class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  #Core Carpe search. Searches groups and users
  def search_core
    if params[:q]
      q = params[:q].strip
    else
      q = ""
    end
    
    if q != "" #only search if it's not silly
      @users = User.where('name LIKE ?', "%#{q}%").limit(10)
      @users = @users.sort {|a,b|
        a_rank = 0
        b_rank = 0

        
        if a.name.downcase.starts_with?(q.downcase) #if the users name starts with the query
          a_rank = 2 #it's a great match (score 2)
        elsif a.name.downcase.include?(" " + q.downcase) #if the users middle or last name starts with the query
          a_rank = 1 #it's an okay match (score 1)
        end #otherwise we get the default score of 0 for having the query in their name
          
        #repeat for b
        if b.name.downcase.starts_with?(q.downcase)
          b_rank = 2
        elsif b.name.downcase.include?(" " + q.downcase)
          b_rank = 1
        end

        b_rank <=> a_rank #return comparison of ranks, with highest preferred first
      }

      groups = Group.where('name LIKE ?', "%#{q}%").limit(5)
      group_map = groups.map(&:attributes) #returns an array of hash objects of groups
      group_map = group_map.map{|group|
        group[:model_name] = "Group"
        group[:link_url] = group_url(Group.find_by_id(group["id"]))
        group
      }

      user_map = @users.map(&:attributes) #grab all user attributes
      user_map = user_map.map{|user|
        user[:model_name] = "User" #specify what type of object this is
        user[:link_url] = user_url(User.find_by_id(user["id"]))

        # and handle avatars
        unless(User.find_by_id(user["id"]) and User.find_by_id(user["id"]).has_avatar) #if this is a valid user that has no avatar
          user[:image_url] = "http://www.gravatar.com/avatar/?d=mm" #change to the default avatar
        end
        user #and return the users
      }

      render :json => user_map + group_map
    end 
  end

	protected

  # Allow sign up and edit profile to take the name parameter. Needed by devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:account_update) << :name
  end

  # Authorize if a user is signed in and is admin before viewing a pge
  def authorize_admin
  	unless current_user and current_user.admin
  		# flash[:alert] = "Unauthorized access"
  		redirect_to home_path
  		return false
  	end
    return true #return true if the user is admin
  end

  # Authorize if a user is signed in
  def authorize_signed_in
    unless current_user
      flash[:alert] = "You have to be signed in to do that!"
      redirect_to user_session_path
      return false
    end
    return true #return true if the user is signed in
  end
end
