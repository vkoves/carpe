class AddChildEventToEventInvites < ActiveRecord::Migration[5.0]
  def change
    change_table :event_invites do |t|
      t.rename :event_id, :host_event_id
      t.references :hosted_event, foreign_key: { to_table: :events }
    end
  end
end
