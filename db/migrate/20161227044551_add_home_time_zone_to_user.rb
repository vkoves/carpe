class AddHomeTimeZoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :home_time_zone, :string,  :default => "Central Time (US & Canada)"
  end
end
