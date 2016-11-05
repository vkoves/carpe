class Relationship < ActiveRecord::Base
  # Made using https://www.railstutorial.org/book/following_users
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"


  # Confirm this relationship
  def confirm
  	self.confirmed = true
    self.save
  end

  # Deny this relationship
  def deny
  	self.confirmed = false
    self.save
  end
end
