class ChangeNotificationsUniqueIndex < ActiveRecord::Migration[5.1]
  def change
    change_table :notifications do |t|
      t.remove_index [:entity_id, :event]

      t.index [:event, :receiver_id, :sender_id, :entity_id, :message],
              unique: true, name: "index_unique_notifications"

    end
  end
end
