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
  belongs_to :user
  belongs_to :event

  has_many :notifications, as: :entity, dependent: :destroy

  validates :event_id, uniqueness: {
    scope: :user_id,
    message: ->(invite, _data) {
      "#{invite.user.name} has already been invited."
    }
  }
end
