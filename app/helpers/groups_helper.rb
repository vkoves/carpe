module GroupsHelper
  # returns an array of symbols indicating what roles the current user
  # can assign a group member (UserGroup) to
  def assignable_roles(membership)
    available_roles = UsersGroup.roles.keys.select do |to_role|
      (can? :update, membership, to_role) and to_role != membership.role
    end

    available_roles.sort_by { |role| UsersGroup.role_priority(role) }
  end
end
