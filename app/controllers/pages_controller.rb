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

    #redirect_to "/users"
    render :json => {"action" => "promote", "uid" => params[:id]}
  end

  def destroy_user
    user = User.find(params[:id])

    if current_user.admin
      user.destroy
    end

    redirect_to "/admin"
  end

  def admin #admin page
    @past_month_users = User.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    if !current_user or !current_user.admin
      redirect_to "/"
    end
  end

  def sandbox
    if !current_user or !current_user.admin
      redirect_to "/"
    end
  end
end
