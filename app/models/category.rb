class Category < ActiveRecord::Base
	belongs_to :user
	has_many :events
	
	def destroy
    events.destroy_all
    self.delete
	end
	
	#returns whether the current user can see this
	def has_access(user_in)
	  if privacy == "public"
	    return true
	  elsif privacy == "private"
	    return false
	  elsif privacy == "friends"
	    if user_in and user_in.friend_status(user) == "friend"
	      return true
	    else
	      return false
	    end
	  end
	end
end
