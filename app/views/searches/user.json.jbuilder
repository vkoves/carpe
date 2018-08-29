json.array! @users do |user|
  json.id user.id
  json.name user.name
  json.image_url user.avatar_url(50)
end
