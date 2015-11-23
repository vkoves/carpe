class FriendshipsController < ApplicationController
  def create
    @friendship = current_user.friendships.build(:friend_id => params[:friend_id])
    @friendship.save
    redirect_to root_url
  end
  
  def destroy
    @friendship = Friendship.find(params[:id])
    if @friendship.user_id == current_user.id or @friendship.friend_id == current_user.id
      @friendship.destroy
      flash[:alert] = "Friend removed."
    else
      flash[:alert] = "You aren't friends with that person, so you can't remove them!"
    end
    redirect_to "/u/" + current_user.id.to_s
  end
  
  def confirm #mark a friendship as confirmed. You're friends!
    @friendship = Friendship.find(params[:id])
    
    if @friendship.friend_id == current_user.id #make sure the user receiving is the one accepting
      @friendship.confirmed = true;
      @friendship.save
    end
    redirect_to "/u/" + current_user.id.to_s
  end
  
  def deny #mark a friendship as not confirmed
    @friendship = Friendship.find(params[:id])
     
    if @friendship.friend_id == current_user.id #make sure the user receiving is the one accepting
      @friendship.confirmed = false;
      @friendship.save
    end
    redirect_to "/u/" + current_user.id.to_s
  end
end
