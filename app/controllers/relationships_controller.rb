class RelationshipsController < ApplicationController
  before_filter  :authorize_signed_in # make sure a user is signed in before allowing any of this

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js { render json: @user.id }
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def confirm
  end

  def deny
  end
end
