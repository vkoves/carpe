class GroupsController < ApplicationController
  before_action :authorize_signed_in!

  def index
    @joinable_groups = Group.where(privacy: [:public_group, :private_group])
                         .where.not(id: current_user.groups)
                         .page(params[:page]).per(25)
  end

  def show
    @group = Group.from_param(params[:id])
    authorize! :view, @group

    # forces custom urls to be displayed (when applicable)
    if params[:id].is_int? and @group.has_custom_url?
      redirect_to group_path(@group), status: :moved_permanently
    end

    @view = params[:view]&.to_sym || :overview

    case @view
    when :manage_members
      authorize! :manage_members, @group
    when :members
      @members = @group.members.page(params[:page]).per(25)
    when :overview
      @upcoming_events = @group.events_in_range(DateTime.now - 1.day, DateTime.now.end_of_day + 10.day, current_user.home_time_zone)
      @activity = (@group.members + @group.categories + @group.events).sort_by(&:created_at).reverse.first(2)
    when :schedule
      @read_only = false if @group.role(current_user) == :owner
    end
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.from_param(params[:id])
    @role = @group.role(current_user)
    authorize! :update, @group
  end

  def create
    @group = Group.new group_create_params

    if @group.save
      @group.add(current_user, as: :owner)
      redirect_to @group, notice: "Group was successfully created."
    else
      render :new
    end
  end

  def update
    @group = Group.from_param(params[:id])
    authorize! :update, @group

    if @group.update group_create_params
      redirect_to @group, notice: "Group was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @group = Group.from_param(params[:id])
    authorize! :destroy, @group

    if @group.destroy
      redirect_to groups_url, notice: "Group was successfully destroyed."
    else
      redirect_to request.referrer, alert: "Couldn't destroy group"
    end
  end

  def join
    @group = Group.from_param(params[:id])
    @user = current_user

    if @group.public_group?
      @group.add(@user)
    elsif @group.private_group?
      Notification.create(sender: current_user, receiver: @group.owner,
                          event: :group_invite_request, entity: @group)
    end

    redirect_to request.referrer
  end

  def leave
    group = Group.from_param(params[:id])
    old_role = group.role(current_user)
    membership = UsersGroup.find_by(group: group, user: current_user, accepted: true)

    if membership
      membership.destroy

      if group.empty?
        group.destroy
      elsif old_role == :owner
        # looks like you're today's winner!
        UsersGroup.find_by(group: group).update(role: :owner)
      end

    else
      redirect_to request.referrer, alert: "You can't leave a group you are not in!"
      return
    end

    redirect_to groups_path
  end

  protected

  # 'edit' and 'new' will redirect back to the group modified
  def after_update_path_for(resource)
    group_path resource
  end

  private

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to request.referrer, alert: exception.message
  end

  def group_create_params
    params.require(:group)
          .permit(:name, :description, :avatar, :banner,
                  :posts_preapproved, :custom_url, :privacy)
  end
end
