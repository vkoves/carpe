class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by_id(params[:id]) #fetch the user by the URL passed id
    @all_friends = @user.all_friendships #and fetch all of the user's friends
    @profile = false
    if current_user and current_user == @user #this is the user looking at their own profile
      @profile = true
    end
  end
end
