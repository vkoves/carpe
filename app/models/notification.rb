class Notification < ApplicationRecord
  enum event: { system_message: 0, follow_request: 1, user_message: 2 }

  belongs_to :entity, polymorphic: true, dependent: :destroy

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id', dependent: :destroy
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id', dependent: :destroy

  scope :unread, -> { where(viewed: false) }
end
