class GroupsController < ApplicationController
  before_action :authorize_signed_in, except: [:index]
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @visible_groups = Group.where(privacy: 'public_group')
                           .page(params[:page]).per(25)

    respond_to do |format|
      format.html
      format.js {
        render partial: "shared/lazy_list_loader",
               locals: { collection: @visible_groups,
                         item_name: :group,
                         partial: "big_group_card" }
      }
    end
  end

  def show
    unless @group.viewable_by? current_user
      redirect_to groups_path, alert: "You don't have permission to view this group"
    end

    @role = @group.get_role current_user
    @view = params[:view]&.to_sym || :schedule

    case @view
    when :manage_members
      authorize_roles! [:owner, :moderator]
    when :members
      @members = @group.users.page(params[:page]).per(25)

      respond_to do |format|
        format.html
        format.js {
          render partial: "shared/lazy_list_loader",
                 locals: { collection: @members,
                           item_name: :member,
                           partial: "basic_user_block" }
        }
      end

    when :overview
      @upcoming_events = current_user.events_in_range(DateTime.now - 5.day, DateTime.now.end_of_day + 10.day)
    end
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
      UsersGroup.create user: current_user, group: @group, role: :owner, accepted: true
      redirect_to @group, notice: "Group was successfully created."
    else
      render :new
    end
  end

  def update
    @membership = UsersGroup.find_by group_id: @group.id, user_id: current_user.id, accepted: false
    @membership[:accepted] = true
    @membership.save

    if params[:group] && (@group.update group_create_params)
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

  def authorize_roles!(authorized_roles)
    unless authorized_roles.include? @role
      redirect_to groups_path, alert: "You don't have permission to access that page!"
    end
  end
end
