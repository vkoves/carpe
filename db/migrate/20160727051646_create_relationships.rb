class CreateRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.boolean :confirmed

      t.timestamps null: false
    end
  end
end
