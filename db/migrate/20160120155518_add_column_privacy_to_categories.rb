class AddColumnPrivacyToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :privacy, :string
  end
end
