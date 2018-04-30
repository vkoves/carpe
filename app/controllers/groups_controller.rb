class GroupsController < ApplicationController
  before_action :authorize_signed_in!

  def index
    @visible_groups = Group.where(privacy: 'public_group')
                           .page(params[:page]).per(25)

    @joinable_groups = Array.new

    public_groups = Group.where(privacy: 'public_group').page(params[:page]).per(25)
    public_groups.each do |group|
      if !group.in_group?(current_user)
        @joinable_groups.push(group);
      end
    end

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
    @group = Group.from_param(params[:id])

    unless @group.viewable_by? current_user
      redirect_to groups_path, alert: "You don't have permission to view this group"
    end

    @role = @group.get_role current_user
    @view = params[:view]&.to_sym || :overview

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
      @upcoming_events = @group.events_in_range(DateTime.now - 1.day, DateTime.now.end_of_day + 10.day, current_user.home_time_zone)
      @activity = (@group.users + @group.categories + @group.events).sort_by(&:created_at).reverse.first(2)
    end
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.from_param(params[:id])
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
    @group = Group.from_param(params[:id])
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
    @group = Group.from_param(params[:id])
    @group.destroy
    redirect_to groups_url, notice: "Group was successfully destroyed."
  end

  protected

  # 'edit' and 'new' will redirect back to the group modified
  def after_update_path_for(resource)
    group_path resource
  end

  private

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
