class CreateCategories < ActiveRecord::Migration[4.2]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :color
      t.string :user

      t.timestamps null: false
    end
  end
end
