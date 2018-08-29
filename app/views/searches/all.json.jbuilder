json.array! @users_and_groups do |profile|
  json.id profile.id
  json.name profile.name
  json.image_url profile.avatar_url(50)
  json.link_url polymorphic_path(profile)
  json.model_name profile.class.name
end
