class CreateUsersEvents < ActiveRecord::Migration
  def change
    create_table :users_events do |t|
      t.string :role
      t.integer :status
      t.integer :sender_id
      t.integer :event_id
      t.integer :recipient_id

      t.timestamps null: false
    end
  end
end
