class GroupsController < ApplicationController
  def index
    @groups = current_user.groups.all
  end
  
  def create
    @group = Group.create(params.permit(:name))
    @group.users.append(current_user)
    @user_group = UsersGroup.where(user_id: current_user.id, group_id: @group.id).first
    @user_group.role = "owner"
    @user_group.save
    redirect_to "/groups"
  end
  
  def destroy
    Group.destroy(params[:id])
    redirect_to "/groups"
  end
  
  def update
    @group = Group.find(params[:id])
    @group.update_attributes(params.require(:group).permit(:name))
    @group.save
    redirect_to "/groups"
    #render :text => @group.name
  end
  
  def edit
    @group = Group.find(params[:id])
  end
  
  def show
    @group = Group.find(params[:id])
  end
end