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
    @relationship = Relationship.find(params[:id])
    @user = @relationship.followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js { render json: @relationship.id }
    end
  end

  def update
    @relationship = Relationship.find(params[:id])
    if @relationship.update_attribute(:confirmed, params[:relationship][:confirmed])
      if params[:relationship][:confirmed] == true
        render :json => {"action" => "confirm_friend", "fid" => params[:id], "conf" => params[:relationship][:confirmed]}
      else
        render :json => {"action" => "deny_friend", "fid" => params[:id]}
      end
    end
  end
end
