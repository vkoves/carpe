class EventInvite < ApplicationRecord
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

  belongs_to :sender, class_name: "User", foreign_key: :sender_id,
                      default: -> { Current.user }

  belongs_to :user
  belongs_to :host_event, class_name: "Event", optional: true
  belongs_to :hosted_event, class_name: "Event", optional: true,
                            dependent: :destroy

  has_many :notifications, as: :entity, dependent: :destroy

  validates :host_event_id, uniqueness: {
    scope: :user_id,
    message: lambda do |invite, _data|
      "#{invite.user.name} has already been invited."
    end
  }

  after_create :send_invite_email

  # Creates a duplicate event on the invited user's schedule
  # (referred to as a hosted event) that will need to be kept
  # in sync with the host event (base_event_id).
  def make_hosted_event_for_user!
    new_event = host_event.dup
    new_event.user_id = user_id
    new_event.base_event_id = host_event_id
    new_event.category_id = user.event_invite_category!.id
    new_event.save!

    update(hosted_event: new_event)
  end

  def accept!
    update(status: :accepted)
    make_hosted_event_for_user!
  end

  def maybe!
    update(status: :maybe)
    make_hosted_event_for_user!
  end

  def decline!
    update(status: :declined)
  end

  private

  def send_invite_email
    UserNotifier.event_invite_email(user, self).deliver_later
  end
end
