class AddColumnUserIdToRepeatExceptions < ActiveRecord::Migration
  def change
    add_column :repeat_exceptions, :user_id, :integer
    add_index :repeat_exceptions, :user_id
  end
end
