class GroupInvitationsController < ApplicationController
  before_action :authorize_signed_in
  before_action :set_users_and_groups

  # user joins a group
  def join_group
    # prevent possible duplicate entries
    return redirect_to groups_path if @group.in_group? @user

    if @group.public_group?
      UsersGroup.create group_id: @group.id, user_id: @user.id, accepted: true
    elsif @group.private_group?
      UsersGroup.create group_id: @group.id, user_id: @user.id, accepted: false
    end

    # TODO: notify private group that user would like to join
    redirect_to groups_path
  end

  # user leaves group
  def leave_group
    @membership = @user.find_by group_id: @group.id, user_id: @user.id, accepted: true
    @membership.destroy

    # TODO: notify group (who?) that a user has left?
  end

  # group invites user(s)
  def invite_users
    @group.users << @user
    # invite is displayed in user notifications
  end

  # group removes user(s)
  def remove_users
    @membership = UsersGroup.find_by group_id: @group.id, user_id: @user.id, accepted: true
    @membership.destroy

    Notification.create sender: @group,
                        receiver: @user,
                        message: "You've been removed from the group '#{@group.name}''"
  end

  def update
    @invite = UsersGroup.find_by group_id: @group.id, user_id: @user.id, accepted: false

    if params[:confirm] == "true"
      render json: { action: "confirm_friend", fid: @invite.id }
      @invite.update_attribute confirmed: true
    else
      render json: { action: "deny_friend", fid: @invite.id }
      @invite.destroy
    end
  end

  private

  def set_users_and_groups
    @group = Group.find params[:group_id]
    @user = User.find params[:user_id]
  end
end