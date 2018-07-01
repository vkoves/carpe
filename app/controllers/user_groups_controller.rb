class UserGroupsController < ApplicationController
  before_action :authorize_signed_in!

  # user joins a group
  def invite_to_group
    @group = Group.find params[:group_id]
    @user = User.find params[:user_id]

    # prevent possible duplicate entries
    return redirect_to groups_path if @user.in_group?(@group)

    user_group = @group.invite(@user)
    Notification.create(
      sender: current_user,
      receiver: @user,
      entity: user_group,
      event: :group_invite
    )

    # this redirects back to current page
    redirect_to request.referrer
  end
  # group invites user(s)
  def new
    @group.invite(@user)
    # invite is displayed in user notifications
  end

  # group removes user(s)
  def destroy
    @membership = UsersGroup.find_by! params[:id]
    @membership.destroy

    msg = "You've been removed from the group '#{@membership.group.name}''"
    Notification.create sender: @group, receiver: @user, message: msg
  end

  # group modifies user
  def update
    @membership = UsersGroup.find_by! params[:id]
    @membership.update(params[:update] => params[:to]) if valid_user_update_params?

    redirect_to group_path @membership.group, view: :manage_members
  end

  # user confirms group invite?
  # def update
  #   @invite = UsersGroup.find_by group_id: @group.id, user_id: @user.id, accepted: false
  #
  #   if params[:confirm] == "true"
  #     render json: { action: "confirm_friend", fid: @invite.id }
  #     @invite.update_attribute confirmed: true
  #   else
  #     render json: { action: "deny_friend", fid: @invite.id }
  #     @invite.destroy
  #   end
  # end

  private

  # since the client could manipulate the request, it's essential
  # to verify the update parameters for security & validity.
  def valid_user_update_params?
    permitted_attributes = ["role"]
    return false unless permitted_attributes.include? params[:update]

    case params[:update]
    when "role"
      UsersGroup.roles.include? params[:to]
    end
  end
end
