class EventInvitesController < ApplicationController
  before_action :authorize_signed_in!
  respond_to :json

  def index
    render EventInvite.where(event_id: params[:event_id])
  end

  def create
    batch_create and return if params[:user_ids]

    event_invite = EventInvite.new(invite_create_params)
    event_invite.sender = current_user
    event_invite.save

    send_event_invite_notification(event_invite)

    render event_invite
  end

  def update
    @event_invite = EventInvite.find(params[:id])
    @event_invite.update(event_invite_params)
    head :ok
  end

  def destroy
    @event_invite = EventInvite.find(params[:id])
    @event_invite.destroy
  end

  def setup
    event = Event.find(params[:event_id])

    # first time setup. adds the current user as a host to their own event
    unless event.host_event?
      EventInvite.create(sender: current_user, recipient: current_user,
                         event: event, role: :host)
    end

    render EventInvite.where(event: event)
  end

  private

  def event_invite_params
    params.require(:event_invite).permit(:role, :status)
  end

  def invite_create_params
    params.permit(:event_id, :role, :recipient_id)
  end

  def batch_create
    recipients = User.find(params[:user_ids].split(","))
    event = Event.find(params[:event_id])

    invites = EventInvite.create(recipients.map{ |recipient|
      { sender_id: current_user.id, recipient_id: recipient.id, event_id: event.id }
    })

    good, bad = invites.partition(&:persisted?)
    good.each{ |invite| send_event_invite_notification(invite) }

    if bad.empty?
      render invites
    else
      error_msg = bad.map{ |inv| inv.errors.messages.values }.join(", ")
      render json: { partial: good, errors: error_msg }, status: :unprocessable_entity
    end
  end

  def send_event_invite_notification(event_invite)
    Notification.create(
      sender: current_user,
      receiver: event_invite.recipient,
      event: :event_invite,
      entity: event_invite
    )
  end
end
