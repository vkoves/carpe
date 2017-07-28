
class Group < ActiveRecord::Base
  enum privacy: { public_group: 0, private_group: 1, secret_group: 2 }

  has_many :users_groups
  has_many :users, -> { where users_groups: { accepted: true } }, through: :users_groups

  has_many :categories
  has_many :events
  has_many :repeat_exceptions

  validates_presence_of :name

  has_attached_file :avatar, *Rails.application.config.paperclip_avatar_settings
  validates_attachment :avatar, Rails.application.config.paperclip_avatar_validations

  has_attached_file :banner, *Rails.application.config.paperclip_banner_settings
  validates_attachment :banner, Rails.application.config.paperclip_banner_validations

  # defaults to 'mm', which is a silhouette of a man.
  def make_gravatar_url(size)
    "https://www.gravatar.com/avatar/?default=mm&size=#{size}"
  end

  # Returns true if the group has a non-default avatar, false otherwise.
  def has_avatar?
    avatar.exists?
  end

  def avatar_url(size = 256)
    return make_gravatar_url(size) unless has_avatar?
    size <= 60 ? avatar.url(:thumb) : avatar.url(:profile)
  end

  # Returns the role of /user/ in this group (e.g. 'admin') or
  # nil if the user isn't even a member of this group.
  def get_role(user)
    UsersGroup.find_by(user_id: user.id, group_id: id, accepted: true)&.role
  end

  # Returns true if user is in this group, false otherwise.
  def in_group?(user)
    UsersGroup.exists?(user_id: user.id, group_id: id, accepted: true)
  end

  # can the user access the page at all?
  def can_view?(user)
    # user must be signed in
    return false unless user.present?

    # user must be part of secret group to view it
    return false if secret_group? and not in_group? user

    true
  end

  # can the user view the schedule, group members, etc?
  def can_view_details?(user)
    # user must be able to view the group
    return false unless can_view? user

    # user must be part of the private group
    return false if private_group? and not in_group? user

    true
  end
end
