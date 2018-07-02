# :manage = every action (:create, :update, :destroy, etc)
# :all = every resource

class Ability
  include CanCan::Ability

  def initialize(user)
    can :promote, UsersGroup do |user_group|
      target, group = user_group.user, user_group.group

      role = group.role(user)
      target_role = group.role(target)

      false
    end

    can :manage, RepeatException, user: user
    can(:manage, Event) { |event| user == event.owner or user.in_group?(event.group) }
    can(:manage, Category) { |cat| user == cat.owner or user.in_group?(cat.group) }

    can [:update, :destroy, :manage_members, :invite_members], Group, users_groups: { role: :owner }

    can :view, Group do |group|
      group.public_group? or
        (group.private_group? and user.in_group?(group)) or
        (group.secret_group? and user.in_group?(group))
    end
  end
end