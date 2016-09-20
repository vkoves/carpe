class GroupsController < ApplicationController
  before_filter :authorize_signed_in

  def index
    @groups = current_user.groups.all
  end

  def create
    @group = Group.create(params.permit(:name))
    @group.users.append(current_user)
    @user_group = UsersGroup.where(user_id: current_user.id, group_id: @group.id).first
    @user_group.role = "owner"
    @user_group.save
    redirect_to group_path(@group)
  end

  def destroy
    Group.destroy(params[:id])
    redirect_to "/groups"
  end

  def update
    @group = Group.find(params[:id])
    @group.update_attributes(params.require(:group).permit(:name))
    @group.update_attributes(params.require(:group).permit(:description))
    @group.update_attributes(params.require(:group).permit(:banner_image_url))
    @group.update_attributes(params.require(:group).permit(:image_url))
    @group.update_attributes(params.require(:group).permit(:posts_preapproved))
    @group.save
    redirect_to group_path(@group)

    #render :text => @group.name
  end

  def edit
    @group = Group.find(params[:id])
    @available_roles = %w(owner admin member)
  end

  def potato

  end

  def show
    @group = Group.find(params[:id])
    user_group = UsersGroup.where(user_id: current_user.id, group_id: @group.id)
    if user_group.first
      @role = UsersGroup.where(user_id: current_user.id, group_id: @group.id).first.role
    else
      flash[:alert] = "You aren't a part of that group."
      redirect_to "/groups"
    end
  end

  def add_users
    @group = Group.find(params[:id])
    if params[:uid]
      user = User.find(params[:uid])
      if(params[:del]) #remove the user
        @group.users.delete(user)
      elsif !@group.users.include? user #add the user
        @group.users.append(user)
        notif = Notification.new()
        notif.sender = current_user
        notif.receiver = user #the person creating the friendship should get this notification
        notif.message = " added you to the group " + @group.name
        notif.save
      end
      redirect_to group_path(@group)
    end
    @followers = current_user.followers #and fetch all of the user's friendss
  end
end