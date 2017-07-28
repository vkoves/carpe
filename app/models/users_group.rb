class UsersGroup < ActiveRecord::Base
  enum role: { member: 0, admin: 1, owner: 2, editor: 3 }

  belongs_to :user
  belongs_to :group
end