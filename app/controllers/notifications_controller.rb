class NotificationsController < ApplicationController
  def read_all #Mark all current notifications as read
    @notifications = current_user.notifications
    @notifications.update_all viewed: true
    render :text => "Notifications read!"
  end
end