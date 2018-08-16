class UserGroupsController < ApplicationController
  before_action :authorize_signed_in!

  def destroy
    membership = UsersGroup.find(params[:id])

    member = membership.user
    group = membership.group

    authorize! :destroy, membership
    membership.destroy

    msg = "You've been removed from the group '#{group.name}''"
    Notification.create receiver: member, message: msg

    redirect_to request.referrer
  end

  def update
    membership = UsersGroup.find(params[:id])
    group = membership.group

    authorize! :update, membership, params[:role]
    membership.update(params.permit(:role))

    # owners who give away their role become moderators
    if params[:role] == "owner"
      group.membership(current_user).update(role: :moderator)
    end

    # an owner demoting themself makes someone else the new owner
    if group.owner.nil?
      UsersGroup.where(group: group, accepted: true).where.not(user: current_user)
          .first.update(role: :owner)
    end

    redirect_to request.referrer
  end
end
