class PagesController < ApplicationController
  before_filter :authorize_admin,
                only: [:promote, :admin, :sandbox, :destroy_user, :admin_user_info]

  def promote # promote or demote users admin status
    @user = User.find(params[:id])
    @user.admin = (params[:de] != "true") # they're an admin if not being demoted
    @user.save

    render json: { action: "promote", uid: params[:id] }
  end

  def destroy_user
    user = User.find(params[:id])
    user.destroy

    redirect_to "/admin"
  end

  def admin_user_info
    @user = User.find(params[:id])
    @user_groups = UsersGroup.where(user_id: @user.id)
  end

  def admin #admin page
    @now = Time.zone.now
    @past = @now - 1.months
    
    @past_month_users = User.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events_modified = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:updated_at).count
  end
end
