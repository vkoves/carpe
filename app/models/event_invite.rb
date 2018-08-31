class EventInvite < ApplicationRecord
  enum status: {
    accepted: 0,
    declined: 1,
    maybe: 2
  }

  enum role: {
    guest: 0,
    host: 1
  }

  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id
  belongs_to :event

  validates :event_id, uniqueness: {
    scope: :recipient_id,
    message: ->(invite, _data) {
      "#{invite.recipient.name} has already been invited."
    }
  }
end
