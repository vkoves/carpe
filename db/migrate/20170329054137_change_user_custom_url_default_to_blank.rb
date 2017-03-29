class ChangeUserCustomUrlDefaultToBlank < ActiveRecord::Migration
  def change
    change_column_default :users, :custom_url, ""
    User.where(custom_url: nil).update_all(custom_url: '')
  end
end
