class AddPublicToUsers < ActiveRecord::Migration
  def change
    add_column :users, :public_profile, :boolean, :default => false
  end
end
