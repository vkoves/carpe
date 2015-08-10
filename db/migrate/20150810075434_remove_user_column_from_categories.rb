class RemoveUserColumnFromCategories < ActiveRecord::Migration
  def up
    remove_column :categories, :user
  end

  def down
    remove_column :categories, :user, :string
  end
end
