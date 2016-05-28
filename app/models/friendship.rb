class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User"

  def other_user(user_in) #returns the user that is not the user passed in
  	if user == user_in
  		return friend
  	else
  		return user
  	end
  end
end
