module GroupsHelper
  # returns an array of symbols indicating what roles the current user
  # can assign a group member (UserGroup) to
  def assignable_roles(membership)
    available_roles = UsersGroup.roles.keys.select do |to_role|
      (can? :update, membership, to_role) and to_role != membership.role
    end

    available_roles.sort_by { |role| UsersGroup.role_priority(role) }
  end

  def leave_warning(user_group)
    return nil unless user_group.owner?

    if user_group.group.size == 1
      "Are you sure? The group will be disbanded."
    else
      "Are you sure? Someone else in the group will become the new owner."
    end
  end

  def role_assign_confirmation(role)
    return nil unless role.to_sym == :owner

    "Are you sure? You will be demoted to a moderator."
  end

  def remove_confirmation(user_group)
    if user_group.user == current_user
      "You want to kick yourself? #{leave_warning user_group}"
    end
  end
end
