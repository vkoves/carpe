class RelationshipsController < ApplicationController
  before_action  :authorize_signed_in!

  def create
    @user = User.find(params[:followed_id])
    @relationship = current_user.follow(@user)

    respond_to do |format|
      format.html { redirect_to @user }
      format.js { render json: @user.id }
    end

    send_notification
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    @followed_user = @relationship.followed
    @relationship.follower.unfollow(@followed_user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js { render json: @relationship.id }
    end
  end

  private

  def send_notification
    Notification.create(
      sender: @relationship.follower,
      receiver: @relationship.followed,
      entity: @relationship,
      event: :follow_request
    )
  end
end
