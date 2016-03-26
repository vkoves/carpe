class Group < ActiveRecord::Base
  has_many :users_groups
  has_many :users, :through => :users_groups

  def get_role(user)
  	user_group = UsersGroup.where(user_id: user.id, group_id: self.id).first
  	if user_group
  		return user_group.role
  	else
  		return "none"
  	end
  end
end
