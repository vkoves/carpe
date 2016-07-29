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
        @all_friends = @user.active_relationships #and fetch all of the user's friends
      end
    else
      redirect_to "/404"
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
      else
        @users = User.where('name LIKE ?', "%#{q}%")
      end
    end

    respond_to do |format|
      format.html
      format.json {
        # Convert the users into a hash with the least data needed to show search. Recall that users can see the JSON
        # the search returns in the network tab, so it's crucial we don't pass unused attributes
        user_map = @users.map{|user|
          user_obj = {} #create a hash representing the user

          # Required fields for search - name and image url
          user_obj[:name] = user.name
          user_obj[:image_url] = user.image_url

          # Handle avatars
          unless user and user.has_avatar #if this is a valid user that has no avatar
            user_obj[:image_url] = "http://www.gravatar.com/avatar/?d=mm" #change to the default avatar
          end

          user_obj #and return the user
        }
        render :json => user_map
        #render :json => @users.map(&:attributes)
      }
    end
  end
end
