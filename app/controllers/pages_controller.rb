class PagesController < ApplicationController
  def promote #promote or demote users admin status
    @user = User.find(params[:id])
    if(current_user and current_user.admin)
      if params[:de] == "true" #if demoting
        @user.admin = false
      else
        @user.admin = true
      end
      @user.save
    end
    redirect_to "/users"
  end

  def admin #admin page
    if !current_user or !current_user.admin
      redirect_to "/"
    end
  end
end
