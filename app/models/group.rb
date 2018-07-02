
class Group < ApplicationRecord
  include Profile

  enum privacy: { public_group: 0, private_group: 1, secret_group: 2 }

  has_many :users_groups
  has_many :users, -> { where users_groups: { accepted: true } }, through: :users_groups
  alias_attribute :members, :users

  has_many :categories
  has_many :events
  has_many :repeat_exceptions

  validates_presence_of :name

  # Returns true if the group has a non-default avatar, false otherwise.
  def has_avatar?
    avatar.exists?
  end

  # Returns a url to the avatar with the width in pixels.
  def avatar_url(size = 256)
    return avatar.url(size <= 60 ? :thumb : :profile) if has_avatar? # uploaded avatar
    gravatar_url(size) # default avatar
  end

  # Returns the role of user in this group (e.g. 'admin') or
  # nil if the user isn't even a member of this group.
  def role(user)
    UsersGroup.find_by(user_id: user.id, group_id: id, accepted: true)&.role&.to_sym
  end

  def invited?(user)
    UsersGroup.exists?(user_id: user.id, group_id: id, accepted: false)
  end

  def members_with_role(role)
      User.where(id: UsersGroup.where(group_id: id, accepted: true, role: role).select(:user_id))
  end

  def member?(user)
    members.include?(user)
  end

  def empty?
    members.empty?
  end

  def add(user, as: :member)
    UsersGroup.create group_id: id, user_id: user.id, accepted: true, role: as
  end

  def invite(user, as: :member)
    UsersGroup.create group_id: id, user_id: user.id, accepted: false, role: as
  end

  def membership(user)
    UsersGroup.find_by group_id: id, user_id: user.id
  end
end