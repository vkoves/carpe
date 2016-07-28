class Relationship < ActiveRecord::Base
  # Made using https://www.railstutorial.org/book/following_users
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
end
