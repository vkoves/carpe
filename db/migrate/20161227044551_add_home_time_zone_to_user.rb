class AddHomeTimeZoneToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :home_time_zone, :string,  :default => "Central Time (US & Canada)"
  end
end
