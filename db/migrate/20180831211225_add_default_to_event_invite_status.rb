class AddDefaultToEventInviteStatus < ActiveRecord::Migration[5.1]
  def change
    change_column :event_invites, :status, :integer,
                  default: EventInvite.statuses[:pending_response],
                  null: false
  end
end
