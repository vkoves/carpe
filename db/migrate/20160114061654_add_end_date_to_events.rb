class AddEndDateToEvents < ActiveRecord::Migration
  def change
    add_column :events, :end_date, :date
  end
end
