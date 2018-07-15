class CreateEventInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :event_invites do |t|
      t.string :role, default: "guest", null: false
      t.string :status, comment: "response of the person invited"
      t.references :sender, foreign_key: { to_table: :users }, null: false
      t.references :event, foreign_key: { to_table: :events }, null: false
      t.references :recipient, foreign_key: { to_table: :users }, null: false

      t.timestamps

      t.index [:event_id, :recipient_id], unique: true
    end
  end
end
