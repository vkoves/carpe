class UpdateUsersForEventInvites < ActiveRecord::Migration[5.0]
  def change
    add_reference :users,
                  :default_event_invite_category,
                  foreign_key: { to_table: :categories }
  end
end
