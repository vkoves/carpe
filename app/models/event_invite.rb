class EventInvite < ApplicationRecord
  enum status: {
    accepted: "accepted",
    declined: "declined",
    maybe: "maybe"
  }

  enum role: {
    guest: "guest",
    host: "host"
  }

  validates :event_id, uniqueness: {
    scope: :recipient_id,
    message: ->(invite, data) {
      "#{invite.receiver.name} has already been invited."
    }}

  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :recipient_id
  belongs_to :event

  has_many :invited, class_name: 'User', source: :receiver
end
