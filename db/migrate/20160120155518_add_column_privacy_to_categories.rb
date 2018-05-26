class AddColumnPrivacyToCategories < ActiveRecord::Migration[4.2]
  def change
    add_column :categories, :privacy, :string
  end
end
