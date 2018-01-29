class RemoveUserColumnFromCategories < ActiveRecord::Migration[4.2]
  def up
    remove_column :categories, :user
  end

  def down
    remove_column :categories, :user, :string
  end
end
