class PagesController < ApplicationController
  before_filter  :authorize_admin, :only => [:promote, :admin, :sandbox, :destroy_user, :admin_user_info] #authorize admin on all of these pages

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

  def admin_user_info
    @user = User.find(params[:id])

    @account_creation_time = @user.created_at.strftime('%Y-%m-%d at %H:%M')
    @last_update_time = @user.updated_at.strftime('%Y-%m-%d at %H:%M')
    @last_sign_in_time = @user.last_sign_in_at.strftime('%Y-%m-%d at %H:%M')
    @most_recent_sign_in_time = @user.current_sign_in_at.strftime('%Y-%m-%d at %H:%M')
    @user_groups = UsersGroup.where(user_id: @user.id)
  end

  # <div class="chart-cont">
  # <%= line_chart data: [{name: "Sign In", data: []}] %>
  # </div>

  def admin #admin page
    @now = Time.zone.now
    @past = @now - 1.months
    
    @past_month_users = User.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events_modified = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:updated_at).count
  end
end
