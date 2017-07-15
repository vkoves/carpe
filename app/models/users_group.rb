class UsersGroup < ActiveRecord::Base
  enum role: { MEMBER: 0, ADMIN: 1, OWNER: 2, NONE: 3 }

  belongs_to :user
  belongs_to :group
end