class AddRepeatsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :start_repeat, :datetime
    add_column :events, :end_repeat, :datetime
  end
end
