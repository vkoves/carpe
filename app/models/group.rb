class Group < ApplicationRecord
  has_many :users_groups
  has_many :users, :through => :users_groups

  has_many :categories
  has_many :events
  has_many :repeat_exceptions

  def avatar_url #returns the image_url or a default
    if image_url and !image_url.empty?
      return image_url
    else
      return "https://www.gravatar.com/avatar/?d=mm"
    end
  end

  def get_role(user) #get the role of a user in this group
  	user_group = UsersGroup.where(user_id: user.id, group_id: self.id).first
  	if user_group
  		return user_group.role
  	else
  		return "none"
  	end
  end

  #returns whether the user is in the group
  def in_group?(user)
    role = self.get_role(user)
    role == "none" ? false : true
  end
end
