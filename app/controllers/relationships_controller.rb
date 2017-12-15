class RelationshipsController < ApplicationController
  before_action  :authorize_signed_in!

  def create
    @user = User.from_param(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js { render json: @user.id }
    end
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

  def update
    @relationship = Relationship.find(params[:id])
    if @relationship.update_attribute(:confirmed, params[:relationship][:confirmed])
      if params[:relationship][:confirmed] == "true"
        render :json => {"action" => "confirm_friend", "fid" => params[:id]}
      else
        render :json => {"action" => "deny_friend", "fid" => params[:id]}
      end
    end
  end
end
