class AddAcceptedToUsersGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :users_groups, :accepted, :boolean, default: false
  end
end
