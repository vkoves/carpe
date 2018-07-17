class EventInvitesController < ApplicationController
  before_action :authorize_signed_in!
  before_action :set_event_invite, only: [:show, :edit, :update, :destroy]

  def index
    render EventInvite.where(event_id: params[:event_id])
  end

  def show
  end

  def create
    batch_create and return if params[:user_ids]

    event_invite = EventInvite.new(invite_create_params)
    event_invite.sender = current_user
    event_invite.save

    head :ok
  end

  def update
    @event_invite.update(event_invite_params)
    head :ok
  end

  def destroy
    @event_invite.destroy
    head :ok
  end

  private

  def set_event_invite
    @event_invite = EventInvite.find(params[:id])
  end

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

    if invites.all?(&:persisted?)
      render invites
    else
      error_msg = invites.map{ |inv| inv.errors.messages.values }.join(", ")
      render plain: error_msg, status: :unprocessable_entity
    end
  end
end
