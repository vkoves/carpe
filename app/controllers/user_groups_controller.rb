class UserGroupsController < ApplicationController
  before_action :authorize_signed_in!

  # user joins a group
  def invite_to_group
    group = Group.find params[:group_id]
    user = User.find params[:user_id]

    notif = Notification.create(sender: current_user, receiver: user,
                                entity: group, event: :group_invite)

    render json: { errors: notif.errors.messages.values }
  end

  def destroy
    membership = UsersGroup.find(params[:id])

    member = membership.user
    group = membership.group

    authorize! :destroy, membership
    membership.destroy

    msg = "You've been removed from the group '#{group.name}''"
    Notification.create sender: current_user, receiver: member, message: msg
  end

  def update
    membership = UsersGroup.find_by! params[:id]
    authorize! :update, membership
    membership.update(update_params)

    redirect_to group_path membership.group, view: :manage_members
  end

  private

  def update_params
    params.require(:user_group).permit(:role)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to request.referrer, alert: exception.message
  end
end
