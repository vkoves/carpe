class AddUniqueIndexToUserGroups < ActiveRecord::Migration[5.1]
  def change
    add_index :users_groups, [:user_id, :group_id], unique: true
  end
end
