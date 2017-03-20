class SetCustomUrlToId < ActiveRecord::Migration
  def change
    User.update_all('custom_url=id')
  end
end
