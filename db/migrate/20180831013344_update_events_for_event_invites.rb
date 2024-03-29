class UpdateEventsForEventInvites < ActiveRecord::Migration[5.0]
  def change
    change_table :events do |t|
      t.integer :privacy,
                # This is the private Event privacy (Event.privacies[:privacy_private])
                default: 1, null: false,
                comment: "used by event invites"

      t.references :base_event,
                   foreign_key: { to_table: :events },
                   comment: "used by event invites"
    end
  end
end
