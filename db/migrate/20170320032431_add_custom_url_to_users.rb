class AddCustomUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_url, :string
  end
end
