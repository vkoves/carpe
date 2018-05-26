class AddEndDateToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :end_date, :datetime
  end
end
