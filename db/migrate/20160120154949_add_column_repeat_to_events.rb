class AddColumnRepeatToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :repeat, :string
  end
end
