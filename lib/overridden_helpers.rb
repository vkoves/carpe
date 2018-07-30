module OverriddenHelpers
  def user_path(user, options = {})
    uid = user.has_custom_url? ? user.custom_url : user.id
    options.present? ? "/users/#{uid}?#{options.to_query}" : "/users/#{uid}"
  end

  def group_path(group, options = {})
    gid = group.has_custom_url? ? group.custom_url : group.id
    options.present? ? "/groups/#{gid}?#{options.to_query}" : "/groups/#{gid}"
  end
end