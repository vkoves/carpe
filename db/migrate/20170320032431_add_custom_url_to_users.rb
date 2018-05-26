class AddCustomUrlToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :custom_url, :string
  end
end
