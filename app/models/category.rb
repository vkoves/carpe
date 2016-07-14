class Category < ActiveRecord::Base
	belongs_to :user
	belongs_to :group
	has_many :events
	has_and_belongs_to_many :repeat_exceptions

	def destroy #on category destroy
    	events.destroy_all #destroy all of the category's events
    	self.delete #and then delete the category
	end

	#returns whether the current user can see this
	def has_access?(user_in)
	  if user_in == self.user #if this is the owner, obviously they have acces
	  	return true
	  end

	  if privacy == "public" #if the category is public
	    return true #everyone has access
	  elsif privacy == "private" #if it is private
	  	if self.group and self.group.get_role(user_in) != "none" #if this category has a group, and the user is in it
	  		return true #they have access 
	  	else #if this is not a group category
		    return false #no one has access
		end
	  elsif privacy == "friends" #if it is only viewable by friends
	    if user_in and user_in.friend_status(user) == "friend" #if the user is a friend
	      return true #they can view it
	    else #otherwise
	      return false #they can't
	    end
	  end
	end
end
