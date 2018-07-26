class Category < ApplicationRecord
	belongs_to :user
	belongs_to :group
	has_many :events
	has_and_belongs_to_many :repeat_exceptions

  def destroy
    	events.destroy_all
    	self.delete
	end

	# returns whether the current user can see this category
	def accessible_by?(user)
    return true if user == self.owner
    return true if privacy == "public"

    # must be signed in to view categories past this point
    return false if user.nil?

    # only fellow group members can see 'private' categories
    return self.group&.member?(user) if privacy == "private"

    # only followers can see categories with a 'follower' privacy
    return user.following?(self.owner) if privacy == "followers"
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

  def owner
    self.group ? self.group : self.user
  end
end
