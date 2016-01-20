class AddColumnRepeatToEvents < ActiveRecord::Migration
  def change
    add_column :events, :repeat, :string
  end
end
