class UsersGroup < ApplicationRecord
  enum role: { member: 0, moderator: 1, owner: 2, editor: 3 }

  belongs_to :user
  belongs_to :group

  def confirm
    update(accepted: true)
  end
end
