class Relationship < ApplicationRecord
  # Made using https://www.railstutorial.org/book/following_users
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # Confirm this relationship
  def confirm
    self.confirmed = true
    save
  end

  # Deny this relationship
  def deny
    self.confirmed = false
    save
  end

  # Given a user, return the user that is not them. Useful for activity
  def other_user(user)
    if follower == user
      followed
    else
      follower
    end
  end
end
