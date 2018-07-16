class Category < ApplicationRecord
	belongs_to :user
  alias_attribute :creator, :user

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
	  	if user_in and self.group and self.group.get_role(user_in) != "none" #if this category has a group, and the user is in it
	  		return true #they have access
	  	else #if this is not a group category
		    return false #no one has access
		end
	  elsif privacy == "followers" #if it is only viewable by friends
	    if user_in and user_in.following?(user) #if the user is a friend
	      return true #they can view it
	    else #otherwise
	      return false #they can't
	    end
	  end
	end

	def private_version #returns the event with details hidden
	  private_category = self.dup
	  private_category.id = self.id #categories still need IDs even when private
	  private_category.name = "Private Category"
	  private_category.created_at = nil
	  private_category.updated_at = nil
	  private_category.color = "grey"
	  return private_category
  end

  def get_html_name
	  name.present? ? ERB::Util.html_escape(name) : "<i>Untitled</i>"
  end
end
