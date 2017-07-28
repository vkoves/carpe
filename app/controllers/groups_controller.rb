class GroupsController < ApplicationController
  before_action :authorize_signed_in, except: [:index]
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @visible_groups = Group.all # Group.where privacy: [:public, :private]
  end

  def show
    unless @group.can_view? current_user
      redirect_to groups_path, alert: "You don't have permission to view this group"
    end

    @role = @group.get_role current_user

    @current_page = params[:page]&.to_sym || :schedule
  end

  def new
    @group = Group.new
  end

  def edit
    # uses same form as 'new'
  end

  def create
    @group = Group.new group_create_params

    if @group.save
      current_user.users_groups.create group: @group, role: :owner
      redirect_to @group, notice: "Group was successfully created."
    else
      render :new
    end
  end

  def update
    if @group.update group_create_params
      redirect_to @group, notice: "Group was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_url, notice: "Group was successfully destroyed."
  end

  protected

  # 'edit' and 'new' will redirect back to the group modified
  def after_update_path_for(resource)
    group_path resource
  end

  private

  def set_group
    @group = Group.find params[:id]
  end

  def group_create_params
    params.require(:group)
          .permit(:name, :description, :avatar, :banner,
                  :posts_preapproved, :custom_url, :privacy)
  end
end
