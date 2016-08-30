class PagesController < ApplicationController
  before_filter  :authorize_admin, :only => [:promote, :admin, :sandbox, :destroy_user] #authorize admin on all of these pages

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
    @now = Time.zone.now
    @past = @now - 1.months
    
    @past_month_users = User.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events_modified = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:updated_at).count

    #TEMPORARY - This is a script to convert from friends or to followers
    #It fetches all of a users friends and follows them and has the friend follow
    if true #enabled atm
      User.all.each do |user|
        user.friends.each do |friend|
          user.force_follow(friend)
          friend.force_follow(user)
        end
      end
    end
  end
end
