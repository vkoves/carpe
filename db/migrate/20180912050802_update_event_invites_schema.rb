class UpdateEventInvitesSchema < ActiveRecord::Migration[5.1]
  def change
    change_table :event_invites do |t|
      t.rename :receiver_id, :user_id
    end

    change_table :events do |t|
      t.boolean :guests_can_invite, default: false, null: false
      t.boolean :guest_list_hidden, default: false, null: false
    end
  end
end
