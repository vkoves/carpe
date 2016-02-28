class NotificationsController < ApplicationController
  def read_all #Mark all current notifications as read
    @notifications = current_user.notifications
    @notifications.update_all viewed: true
    current_user.inverse_friendships.update_all viewed: true
    render :json => current_user.inverse_friendships
  end
end