class AddTimestampToUsersGroup < ActiveRecord::Migration[5.1]
  def change
    add_column :users_groups, :created_at, :datetime, null: false, :default => 0
    add_column :users_groups, :updated_at, :datetime, null: false, :default => 0
  end
end
