# :manage = every action (: , :update, :destroy, etc)
# :all = every resource

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :manage_members, :edit_schedule, :invite_members, to: :moderator_actions

    can :show, Group do |grp|
      grp.public_group? || grp.private_group? || (grp.secret_group? && user&.in_group?(grp))
    end

    can(:view_details, Group) { |grp| grp.public_group? || user&.in_group?(grp) }

    # must be signed in past this point
    return unless user.present?

    can :manage, RepeatException, group: nil, user: user
    can :manage, RepeatException, group: { users_groups: { user: user, role: [:owner, :moderator, :editor] } }

    # Can manage events in groups where the user is of any role IF the user is the owner
    can :manage, Event, group: { users_groups: { user: user, role: [:owner, :moderator, :editor, :member] } }

    # Can edit events they own, UNLESS it is hosted (they are a guest), in which
    # case only the category_id can be changed.
    can(:update, Event) { |event| can_edit_event?(user, event) }

    # Can destroy events they own
    can :destroy, Event, group: nil, user: user
    can :create, Event, group: nil, user: user

    can :manage, Category, group: nil, user: user
    can :manage, Category, group: { users_groups: { user: user, role: [:owner, :moderator, :editor] } }

    can :manage, Group, users_groups: { user: user, role: :owner }
    can :moderator_actions, Group, users_groups: { user: user, role: :moderator }

    can :manage, UsersGroup, group: { users_groups: { user: user, role: :owner } }
    can(:update, UsersGroup) { |membership, to_role| can_assign_role?(user, membership, to_role) }
  end

  private

  def can_assign_role?(user, membership, to_role)
    assigner_role = membership.group.role(user)

    # besides owners, only moderators can promote/demote people
    return false unless assigner_role == :moderator

    # moderators can only assign roles that are below their own (i.e. member and editor)
    return true if UsersGroup.role_priority(to_role) < UsersGroup.role_priority(assigner_role)
  end

  # Given an event and the requested changes, returns whether the changes can be
  # mader
  def can_edit_event?(user, event)
    # If user is not the owner, return
    return false unless event.user == user

    # If not a hosted_event, user can change ANYTHING
    return true unless event.hosted_event?

    changed_keys = []

    event.changes.each do |key, value|
      # Filter out changes from nil to "", since schedules_controller does that
      changed_keys.push(key) unless value ==  "" && event[key].nil?
    end

    # Check for intersection of change keys and the synced event attibutes. We
    # consider those to be protected
    invalid_change_keys = changed_keys & Event::SYNCED_EVENT_ATTRIBUTES

    # Change is valid for hosted event ONLY if nothing was changed that is synced
    invalid_change_keys.empty?
  end
end
