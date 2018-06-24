class GroupsController < ApplicationController
  before_action :authorize_signed_in!

  def index
    @visible_groups = Group.where(privacy: 'public_group')
                           .page(params[:page]).per(25)

    @joinable_groups = Array.new

    public_groups = Group.where(privacy: 'public_group').page(params[:page]).per(25)
    public_groups.each do |group|
      unless current_user.in_group?(group)
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
    @role = @group.role(current_user)
    @view = params[:view]&.to_sym || :overview

    authorize! :view, @group

    case @view
    when :manage_members
      authorize! :manage_members, @group
    when :members
      @members = @group.members.page(params[:page]).per(25)

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
      @activity = (@group.members + @group.categories + @group.events).sort_by(&:created_at).reverse.first(2)
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

    if params[:group] && (@group.update group_create_params)
      redirect_to @group, notice: "Group was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @group = Group.from_param(params[:id])
    if(@group.destroy)
      redirect_to groups_url, notice: "Group was successfully destroyed."
    else
      redirect_to request.referrer, alert: "Couldn't destroy group"
    end
  end

  def join
    @group = Group.from_param(params[:id])
    @user = current_user

    # prevent possible duplicate entries
    return redirect_to groups_path if @user.in_group? @group

    if @group.public_group?
      @group.add(@user)
    elsif @group.private_group?
      if @group.invited? @user
        @group.membership(@user).confirm
      else
        @group.invite(@user) # TODO: This is a bug
      end
    elsif @group.secret_group?
      if @group.invited? @user
        @group.membership(@user).confirm
      end
    end

    # TODO: notify private group that user would like to join
    # this redirects back to current page
    redirect_to request.referrer
  end

  def leave
    @group = Group.from_param(params[:id])
    @user = current_user

    @membership = UsersGroup.find_by group_id: @group.id, user_id: @user.id, accepted: true
    if(@membership)
      @membership.destroy
    else
      redirect_to request.referrer, alert: "You can't leave a group you are not in!"
      return
    end

    # TODO: notify group (who?) that a user has left?
    if @group.public_group?
      redirect_to request.referrer
    else
      redirect_to groups_path
    end
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

  rescue_from CanCan::AccessDenied do
    redirect_to groups_path, alert: "You don't have permission to do that!"
  end
end
