class NotificationsController < ApplicationController
  def read
    @notifications = current_user.notifications
    @notifications.update_all viewed: true
    render plain: ""
  end

  # Notification responses/updates are routed through here.
  def update
    @notification = Notification.find(params[:id])

    # dispatches call to private method (if implemented)
    self.send(@notification.event) if self.respond_to?(@notification.event, true)

    @notification.destroy
    render json: {}, status: :ok
  end

  def destroy
    notif = Notification.find(params[:id])
    notif.destroy
    render plain: "hurrah"
  end

  private

  def follow_request
    relationship = @notification.entity

    if params[:response] == "confirm"
      relationship.update(confirmed: true)
    elsif params[:response] == "deny"
      relationship.destroy
    end
  end

  def group_invite
    group = @notification.entity
    group.add(current_user) if params[:response] == "accepted"
  end

  def group_invite_request
    group = @notification.entity

    if params[:response] == "accepted"
      group.add(@notification.sender)
      
      Notification.create!(
        receiver: @notification.sender,
        message: "You're now a member of #{group.name}!"
      )
    end
  end
end