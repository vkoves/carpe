class CreateEventInvites < ActiveRecord::Migration[5.1]
  def change
    create_table :event_invites do |t|
      t.integer :role, default: EventInvite.roles[:guest], null: false
      t.integer :status, comment: "rsvp of the invited user"

      t.references :sender, foreign_key: { to_table: :users }, null: false
      t.references :recipient, foreign_key: { to_table: :users }, null: false
      t.references :event, foreign_key: { to_table: :events }, null: false

      t.timestamps

      t.index [:event_id, :recipient_id], unique: true
    end
  end
end
