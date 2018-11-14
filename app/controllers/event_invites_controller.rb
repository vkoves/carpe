class EventInvitesController < ApplicationController
  before_action :authorize_signed_in!

  def create
    batch_create && return if params[:user_ids]

    render plain: "only batch creation is currently supported"
  end

  private

  def batch_create
    invites = EventInvite.create(batch_create_params)

    sent = invites.select(&:persisted?)
    sent.each { |invite| Notification.send_event_invite(invite) }

    render invites
  end

  def batch_create_params
    users = User.find(params[:user_ids].split(","))
    event = Event.find(params[:event_id])

    users.map { |user| { user: user, event: event } }
  end
end
