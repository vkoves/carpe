# :manage = every action (:create, :update, :destroy, etc)
# :all = every resource

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :manage_members, :edit_schedule, :invite_members, to: :moderator_actions

    can :show, Group do |grp|
      grp.public_group? or grp.private_group? or (grp.secret_group? and user&.in_group?(grp))
    end

    can(:view_details, Group) { |grp| grp.public_group? or user&.in_group?(grp) }

    # must be signed in past this point
    return false unless user.present?

    can :manage, RepeatException, group: nil, user: user
    can :manage, RepeatException, group: { users_groups: { user: user, role: [:owner, :moderator, :editor] } }

    can :manage, Event, group: nil, user: user
    can :manage, Event, group: { users_groups: { user: user, role: [:owner, :moderator, :editor, :member] } }

    can :manage, Category, group: nil, user: user
    can :manage, Category, group: { users_groups: { user: user, role: [:owner, :moderator, :editor] } }

    can :manage, Group, users_groups: { user: user, role: :owner }
    can :moderator_actions, Group, users_groups: { user: user, role: :moderator }

    can :manage, UsersGroup, group: { users_groups: { user: user, role: :owner } }
    can(:update, UsersGroup) { |*args| can_assign_role?(user, *args) }
  end

  private

  def can_assign_role?(user, membership, to_role)
    assigner_role = membership.group.role(user)

    # besides owners, only moderators can promote/demote people
    return false unless assigner_role == :moderator

    # moderators can only assign roles that are below their own (i.e. member and editor)
    return true if UsersGroup.role_priority(to_role) < UsersGroup.role_priority(assigner_role)
  end
end
