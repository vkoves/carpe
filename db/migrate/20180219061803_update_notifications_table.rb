class UpdateNotificationsTable < ActiveRecord::Migration[5.1]
  def self.up
    # enforce database integrity
    change_column :notifications, :receiver_id, :integer, null: false

    Notification.where(viewed: nil).update_all(viewed: false)
    change_column :notifications, :viewed, :boolean, default: false, null: false

    # notifications reference other objects (i.e. it's a polymorphic association)
    add_column :notifications, :entity_id, :integer
    add_column :notifications, :entity_type, :string
    add_index :notifications, [:entity_id, :entity_type]

    # same model may have several different notification types
    add_column :notifications, :event, :integer,
               default: Notification.events[:system_message], null: false

    add_index :notifications, [:entity_id, :event], unique: true
  end

  def self.down
    change_column :notifications, :receiver_id, :integer, null: true
    change_column :notifications, :viewed, :boolean, null: true

    remove_column :notifications, :entity_id
    remove_column :notifications, :entity_type
    remove_column :notifications, :event
  end
end
