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

  def status #returns text indicating the status of the friendship
    if confirmed == true
      return "friend"
    elsif confirmed == false
      return "denied"
    else
      return "pending"
    end
  end
end
