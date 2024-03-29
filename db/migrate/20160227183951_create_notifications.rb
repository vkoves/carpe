class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.integer :receiver_id
      t.integer :sender_id
      t.string :message
      t.boolean :viewed, :default => false
      t.timestamps null: false
    end
  end
end
