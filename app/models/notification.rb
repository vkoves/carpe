class Notification < ApplicationRecord
  enum event: { system_message: 0, follow_request: 1, user_message: 2, group_invite: 3,
                group_invite_request: 4, event_invite: 5 }

  belongs_to :entity, polymorphic: true, optional: true

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id', optional: true
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  scope :unread, -> { where(viewed: false) }

  validates :event, uniqueness: {
    scope: [:receiver_id, :sender_id, :entity_id, :message],
    message: "This notification already exists"
  }
end
