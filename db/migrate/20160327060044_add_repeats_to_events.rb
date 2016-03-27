class AddRepeatsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :repeat_start, :date
    add_column :events, :repeat_end, :date
  end
end
