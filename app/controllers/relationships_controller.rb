class RelationshipsController < ApplicationController
  before_action  :authorize_signed_in!

  def create
    @followed_user = User.find(params[:followed_id])
    @relationship = current_user.follow(@followed_user)

    send_notification
    render json: {}
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    @followed_user = @relationship.followed
    @relationship.follower.unfollow(@followed_user)

    render json: { new_link: relationships_path(followed_id: @followed_user.id) }
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
