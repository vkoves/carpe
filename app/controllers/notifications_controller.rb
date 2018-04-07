class NotificationsController < ApplicationController
  def read_all #Mark all current notifications as read
    @notifications = current_user.notifications
    @notifications.update_all viewed: true
    render plain: ""
  end

  # Notification updates are routed through here.
  def updated
    @notification = Notification.find(params[:id])

    unless valid_notification?
      render plain: "Unrecognized notification type", status: :bad_request and return
    end

    # dispatches call to private method (if implemented)
    self.send(@notification.event) if self.respond_to?(@notification.event, true)
  end

  private

  def valid_notification?
    Notification.events.key?(@notification.event)
  end

  def follow_request
    relationship = @notification.entity

    if params[:response] == "confirm"
      relationship.update(confirmed: true)
      render json: { action: "confirm_friend", fid: relationship.id }
    elsif params[:response] == "deny"
      relationship.update(confirmed: false)
      render json: { action: "deny_friend", fid: relationship.id }
    end

    @notification.destroy
  end
end