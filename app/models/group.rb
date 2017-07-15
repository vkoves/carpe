class Group < ActiveRecord::Base
  enum privacy: { PUBLIC: 0, PRIVATE: 1, SECRET: 2 }

  has_many :users_groups
  has_many :users, through: :users_groups

  has_many :categories
  has_many :events
  has_many :repeat_exceptions

  # defaults to 'mm', which is a silhouette of a man.
  def make_gravatar_url(size)
    "https://www.gravatar.com/avatar/?default=mm&size=#{size}"
  end

  def avatar_url(size = 256)
    image_url.present? ? image_url : make_gravatar_url(size)
  end

  # Returns the role of /user/ in this group (e.g. 'admin') or
  # "none" if the user isn't even a member of this group.
  def get_role(user)
    UsersGroup.find_by(user_id: user.id, group_id: id)&.role || "none"
  end

  # Returns true if user is in this group, false otherwise.
  def in_group?(user)
    UsersGroup.exists?(user_id: user.id, group_id: id)
  end
end
