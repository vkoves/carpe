class EventInvite < ApplicationRecord
  # Makes EventInvites have a token via ActiveRecord::SecureToken. Learn more:
  # https://blog.bigbinary.com/2016/03/23/has-secure-token-to-generate-unique-random-token-in-rails-5.html
  has_secure_token

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
