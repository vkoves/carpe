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

    can :manage, UsersGroup, group: { user: user, role: :owner }
    can :manage, RepeatException, user: user
    can(:manage, Event) { |event| user == event.owner or user.in_group?(event.group) }
    can(:manage, Category) { |cat| user == cat.owner or user.in_group?(cat.group) }

    can :owner_actions, Group, users_groups: { user: user, role: :owner }
  end
end