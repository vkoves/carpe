class AddPreapprovedPostsToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :posts_preapproved, :boolean
  end
end
