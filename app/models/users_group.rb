class UsersGroup < ApplicationRecord
  enum role: { member: 0, moderator: 1, owner: 2, editor: 3 }

  belongs_to :user
  belongs_to :group

  def confirm
    update(accepted: true)
  end

  def self.role_priority(role)
    case role.to_sym
    when :owner then 4
    when :moderator then 3
    when :editor then 2
    when :member then 1
    end
  end
end
