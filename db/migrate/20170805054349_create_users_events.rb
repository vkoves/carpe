class CreateUsersEvents < ActiveRecord::Migration
  def change
    create_table :users_events do |t|
      t.integer :event_id
      t.string :role
      t.integer :status
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps null: false
    end
  end
end
