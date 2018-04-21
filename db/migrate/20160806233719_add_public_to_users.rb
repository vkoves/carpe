class AddPublicToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :public_profile, :boolean, :default => false
  end
end
