
class Group < ApplicationRecord
  include Profile

  enum privacy: { public_group: 0, private_group: 1, secret_group: 2 }

  has_many :users_groups
  has_many :users, -> { where users_groups: { accepted: true } }, through: :users_groups

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
  def get_role(user)
    UsersGroup.find_by(user_id: user.id, group_id: id, accepted: true)&.role || "none"
  end

  # Returns true if user is in this group, false otherwise.
  def in_group?(user)
    UsersGroup.exists?(user_id: user.id, group_id: id, accepted: true)
  end

  # can the user access the page at all?
  def viewable_by?(user)
    # user must be signed in
    return false unless user.present?

    # user must be part of secret group to view it
    return false if secret_group? and not in_group? user

    true
  end

  def events_in_range(start_date_time, end_date_time, home_time_zone) #returns all instances of events, including cloned version of repeating events
    #fetch not repeating events first
    event_instances = events.where(:date => start_date_time...end_date_time, :repeat => nil).to_a

    #then repeating events
    events.includes(:repeat_exceptions, category: :repeat_exceptions).where.not(repeat: nil).each do |rep_event| #get all repeating events
      event_instances.concat(rep_event.events_in_range(start_date_time, end_date_time, home_time_zone)) #and add them to the event array
    end

    event_instances = event_instances.sort_by(&:date) #and of course sort by date

    return event_instances #and return
  end

  # can the user view the schedule, group members, etc?
  def can_view_details?(user)
    # user must be able to view the group
    return false unless viewable_by? user

    # user must be part of the private group
    return false if private_group? and not in_group? user

    true
  end

  # Returns the count of members matching a role
  # If no role is passed, returns a count of all members
  def members_count(role = nil)
    if role
      self.users_groups.where(role: role, accepted: true).count
    else
      self.users.count
    end
  end
end
