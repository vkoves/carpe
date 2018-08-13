class GroupsController < ApplicationController
  before_action :authorize_signed_in!

  def index
    @joinable_groups = Group.where(privacy: :public_group)
                            .where.not(id: current_user.groups)
                            .page(params[:page]).per(25)
                            .eager_load(:users).references(:users_groups)


    paginate(@joinable_groups, "big_group_card")
  end

  def show
    @group = Group.from_param(params[:id])

    # forces custom urls to be displayed (when applicable)
    if params[:id].is_int? and @group.has_custom_url?
      redirect_to group_path(@group), status: :moved_permanently
    end

    @view = params[:view]&.to_sym || :overview
    @membership = @group.membership(current_user)
    authorize! :show, @group

    case @view
    when :manage_members
      authorize! :manage_members, @group
      @members = @group.users_groups
    when :members
      @members = @group.members.page(params[:page]).per(25)
    when :overview
      @activities = (@group.members + @group.categories + @group.events)
                      .sort_by(&:created_at).reverse.first(2)
    when :schedule
      @read_only = cannot? :edit_schedule, @group
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
      @group.invitation_for(@user)&.destroy # remove outstanding invitations
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
        UsersGroup.where(group: group, accepted: true).where.not(user: current_user)
            .first.update(role: :owner)
      end

    else
      redirect_to request.referrer, alert: "You can't leave a group you are not in!"
      return
    end

    redirect_to groups_path
  end

  def invite_users_search
    query = params[:q]
    render json: {} and return if query.blank?

    group = Group.find(params[:id])
    matched_users = User.where('name LIKE ?', "%#{query}%")
                      .where.not(id: group.members).limit(10)

    users_json = matched_users.map do |user|
      { id: user.id, name: user.name, image_url: user.avatar_url(50) }
    end

    render json: users_json
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
end
