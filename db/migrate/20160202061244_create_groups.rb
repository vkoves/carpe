class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.belongs_to :supplier, index: true
      t.string :name
      t.text :description
      t.string :image_url
      t.timestamps null: false
    end

    create_table :users_groups do |t|
      t.belongs_to :user, index: true
      t.belongs_to :group, index: true
      t.string :role
    end
  end
end
