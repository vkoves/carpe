class AddAcceptedToUsersGroups < ActiveRecord::Migration
  def change
    add_column :users_groups, :accepted, :boolean, default: false
  end
end
