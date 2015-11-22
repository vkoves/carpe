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
      
      if params[:p] == "mutual_friends"
        @mutual_friends = current_user.mutual_friends(@user)
      else
        @all_friends = @user.all_friendships #and fetch all of the user's friends
      end
    else
      redirect_to "/404"
    end
  end
end
