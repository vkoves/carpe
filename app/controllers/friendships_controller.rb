class FriendshipsController < ApplicationController
  def create
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    @friendship.save
    redirect_to root_url
  end
  
  def destroy
    @friendship = Friendship.find(params[:id])
    @friendship.destroy
    redirect_to root_url
  end
end
