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

    can :update, Group, users_groups: { role: :owner }
    can :manage_members, Group, users_groups: { role: [:owner, :moderator] }
    can :invite_members, Group, users_groups: { role: [:owner, :moderator] }

    can :view, Group do |group|
      group.viewable_by?(user)
    end
  end
end