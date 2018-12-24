class UpdateEventsForEventInvites < ActiveRecord::Migration[5.1]
  def change
    change_table :events do |t|
      t.integer :privacy,
                default: Event.privacies[:private_event], null: false,
                comment: "used by event invites"

      t.references :base_event,
                   foreign_key: { to_table: :events },
                   comment: "used by event invites"
    end
  end
end
