class AddTokenToEventInvites < ActiveRecord::Migration[5.2]
  def change
    add_column :event_invites, :token, :string
    add_index :event_invites, :token, unique: true
  end
end
