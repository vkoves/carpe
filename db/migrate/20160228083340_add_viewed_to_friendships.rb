class AddViewedToFriendships < ActiveRecord::Migration
  def change
    add_column :friendships, :viewed, :boolean, :default => false
  end
end
