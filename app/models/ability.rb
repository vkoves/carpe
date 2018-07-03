# :manage = every action (:create, :update, :destroy, etc)
# :all = every resource

class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :manage, :manage_members, :invite_members, to: :owner_actions

    can :view, Group do |grp|
      grp.public_group? or grp.private_group? or (grp.secret_group? and user.in_group?(grp))
    end

    # must be signed in past this point
    return false unless user.present?

    can :manage, RepeatException, group: nil, user: user
    can :manage, RepeatException, group: { users_groups: { user: user, role: :owner } }

    can :manage, Event, group: nil, user: user
    can :manage, Event, group: { users_groups: { user: user, role: :owner } }

    can :manage, Category, group: nil, user: user
    can :manage, Category, group: { users_groups: { user: user, role: :owner } }

    can(:manage, UsersGroup) { |user_group| user_group.group.role(user) == :owner }
    can :owner_actions, Group, users_groups: { user: user, role: :owner }
  end
end