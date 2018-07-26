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
    Notification.create receiver: member, message: msg
  end

  def update
    membership = UsersGroup.find(params[:id])

    authorize! :update, membership, params[:role]
    membership.update(params.permit(:role))

    # promoting someone else to group owner relinquishes ownership of the group
    if params[:role] == "owner"
      membership.group.membership(current_user).update(role: :moderator)
    end

    redirect_to request.referrer
  end
end
