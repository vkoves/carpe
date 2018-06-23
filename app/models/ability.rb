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

    can :update, Group do |group|
      group.role(user) == :owner
    end

    can :manage_members, Group do |group|
      role = group.role(user)
      [:owner, :moderator].include?(role)
    end

    can :invite_members, Group do |group|
      role = group.role(user)
      [:owner, :moderator].include?(role)
    end

    can :view, Group do |group|
      group.viewable_by?(user)
    end
  end
end