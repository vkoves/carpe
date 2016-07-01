class AddColumnGroupIdToEventsAndCategories < ActiveRecord::Migration
  def change
    add_column :events, :group_id, :integer
    add_index :events, :group_id

    add_column :categories, :group_id, :integer
    add_index :categories, :group_id
  end
end
