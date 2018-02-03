class AddColumnGroupIdToRepeatExceptions < ActiveRecord::Migration[4.2]
  def change
    add_column :repeat_exceptions, :group_id, :integer
    add_index :repeat_exceptions, :group_id
  end
end
