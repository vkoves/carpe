json.array! @users do |user|
  json.id user.id
  json.name user.name
  json.image_url user.user_avatar(50)
  json.link_url user_path(user)
  json.model_name user.class.name
end