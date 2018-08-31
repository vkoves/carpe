class UpdateUsersForEventInvites < ActiveRecord::Migration[5.1]
  def change
    add_reference :users,
                  :default_event_invite_category,
                  foreign_key: { to_table: :events }
  end
end
