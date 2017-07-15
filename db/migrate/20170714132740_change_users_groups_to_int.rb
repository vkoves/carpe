# enum role: { member: 0, admin: 1, owner: 2 }
class ChangeUsersGroupsToInt < ActiveRecord::Migration

  def self.up
    change_column :users_groups, :role, :integer, default: 0
    UsersGroup.where(role: 'member').update_all(role: 0)
    UsersGroup.where(role: 'admin').update_all(role: 1)
    UsersGroup.where(role: 'owner').update_all(role: 2)
  end

  def self.down
    change_column :users_groups, :role, :string, default: nil
    UsersGroup.where(role: 0).update_all(role: 'member')
    UsersGroup.where(role: 1).update_all(role: 'admin')
    UsersGroup.where(role: 2).update_all(role: 'owner')
  end
end
