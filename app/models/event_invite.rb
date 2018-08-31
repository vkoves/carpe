class EventInvite < ApplicationRecord
  enum status: {
    accepted: 0,
    declined: 1,
    maybe: 2,
    pending_response: 3
  }

  enum role: {
    guest: 0,
    host: 1
  }

  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id
  belongs_to :event

  validates :event_id, uniqueness: {
    scope: :receiver_id,
    message: ->(invite, _data) {
      "#{invite.receiver.name} has already been invited."
    }
  }
end
