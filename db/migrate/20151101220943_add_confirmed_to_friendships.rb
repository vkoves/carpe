class AddConfirmedToFriendships < ActiveRecord::Migration[4.2]
  def change
    add_column :friendships, :confirmed, :boolean
  end
end
