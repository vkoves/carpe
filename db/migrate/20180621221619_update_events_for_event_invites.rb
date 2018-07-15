class UpdateEventsForEventInvites < ActiveRecord::Migration[5.1]
  def change
    change_table :events do |t|
      t.string :privacy, default: "private", null: false
      t.references :base_event, foreign_key: { to_table: :events },
                   comment: "used by EventInvites"
    end
  end
end