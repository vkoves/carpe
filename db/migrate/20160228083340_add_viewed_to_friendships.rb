class AddViewedToFriendships < ActiveRecord::Migration[4.2]
  def change
    add_column :friendships, :viewed, :boolean, :default => false
  end
end
