json.array! @users do |user|
  json.id user.id
  json.name user.name
  json.image_url user.user_avatar(50)
end