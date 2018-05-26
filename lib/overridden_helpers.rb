module OverriddenHelpers
  def user_path(user, options = {})
    uid = user.has_custom_url? ? user.custom_url : user.id
    options.present? ? "/users/#{uid}?#{options.to_query}" : "/users/#{uid}"
  end
end