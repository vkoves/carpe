class NotificationsController < ApplicationController
  def read_all #Mark all current notifications as read
    @notifications = current_user.notifications
    @notifications.update_all viewed: true
    render plain: ""
  end

  # Notification updates are routed through here.
  def updated
    @notification = Notification.find(params[:id])

    # dispatches call to private method (if implemented)
    self.send(@notification.event) if self.respond_to?(@notification.event, true)
  end

  private

  def follow_request
    relationship = @notification.entity

    if params[:response] == "confirm"
      relationship.update(confirmed: true)
    elsif params[:response] == "deny"
      relationship.update(confirmed: false)
    else
      render plain: "invalid response", status: :bad_request and return
    end

    @notification.destroy
    render json: {}, status: :ok
  end

  def group_invite
    membership = @notification.entity

    if params[:response] == "accepted"
      membership.confirm
    elsif params[:response] == "denied"
      membership.destroy
    else
      render plain: "invalid response", status: :bad_request and return
    end

    @notification.destroy
    render json: {}, status: :ok
  end
end