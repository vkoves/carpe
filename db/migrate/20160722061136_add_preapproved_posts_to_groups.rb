class AddPreapprovedPostsToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :posts_preapproved, :boolean
  end
end
