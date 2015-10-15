class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by_id(params[:id])
    
    if @user = current_user
      render "profile" #render a different page if this is the current user
    end
  end
end
