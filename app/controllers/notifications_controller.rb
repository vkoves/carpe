class NotificationsController < ApplicationController
  def read_all
    @notifications = current_user.notifications
    @notifications.update_all viewed: true
    render plain: ""
  end

  # Notification responses/updates are routed through here.
  def updated
    @notification = Notification.find(params[:id])

    # dispatches call to private method (if implemented)
    self.send(@notification.event) if self.respond_to?(@notification.event, true)

    @notification.destroy
    render json: {}, status: :ok
  end

  private

  def follow_request
    relationship = @notification.entity

    if params[:response] == "confirm"
      relationship.update(confirmed: true)
    elsif params[:response] == "deny"
      relationship.update(confirmed: false)
    end
  end

  def group_invite
    group = @notification.entity
    group.add(current_user) if params[:response] == "accepted"
  end

  def group_invite_request
    group = @notification.entity
    group.add(@notification.sender) if params[:response] == "accepted"
  end
end