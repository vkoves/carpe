class Notification < ApplicationRecord
  # Events define the types of notifications. DO NOT CHANGE EXISTING EVENTS
  enum event: { system_message: 0, follow_request: 1, user_message: 2, group_invite: 3,
                group_invite_request: 4, event_invite: 5, event_update: 6 }

  belongs_to :entity, polymorphic: true, optional: true

  belongs_to :sender, class_name: "User", foreign_key: "sender_id",
             optional: true, default: -> { Current.user }

  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"

  scope :unread, -> { where(viewed: false) }

  validates :event, uniqueness: {
    scope: [:receiver_id, :sender_id, :entity_id, :message],
    message: "This notification already exists"
  }

  def self.send_event_invite(invite)
    Notification.create(
      receiver: invite.user,
      event: :event_invite,
      entity: invite
    )
  end

  def self.send_event_update(user, event)
    Notification.create(
      receiver: user,
      event: :event_update,
      entity: event,
      message: "The event \"#{event.name}\" has been updated. Review the event in your schedule."
    )
  end
end
