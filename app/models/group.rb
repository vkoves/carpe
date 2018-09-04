
class Group < ApplicationRecord
  include Profile

  enum privacy: { public_group: 0, private_group: 1, secret_group: 2 }

  has_many :users_groups, dependent: :destroy
  has_many :users, -> { where users_groups: { accepted: true } }, through: :users_groups
  alias_attribute :members, :users

  has_many :categories, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :repeat_exceptions, dependent: :destroy
  has_many :notifications, as: :entity, dependent: :destroy

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
    invitation_for(user).exists?
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

  def size
    members.size
  end

  def add(user, as: :member)
    UsersGroup.create group_id: id, user_id: user.id, accepted: true, role: as
  end

  def membership(user)
    return nil if user.nil?
    UsersGroup.find_by group_id: id, user_id: user.id
  end

  def owner
    User.find_by(id: UsersGroup.where(group_id: id, role: :owner).select(:user_id))
  end

  def pending_invite_request?(user)
    # optimization: invite requests are only necessary for private and secret groups
    return false if public_group?

    Notification.exists?(event: :group_invite_request, sender: user, entity: self)
  end

  def invitation_for(user)
    Notification.find_by(event: :group_invite, receiver: user, entity: self)
  end
end