class EventInvitesController < ApplicationController
  before_action :disable_on_production, except: [:email_action]
  before_action :authorize_signed_in!, except: [:email_action]
  before_action :validate_token, only: [:email_action]

  def create
    batch_create && return if params[:user_ids]

    render plain: "only batch creation is currently supported"
  end

  def destroy
    invite = EventInvite.find(params[:id])

    invite.destroy!

    render plain: "Event Invite deleted"
  end

  # Called when clicking the links in an event invite email
  def email_action
    # Do not allow setting status back to pending
    if params[:new_status] != "pending_response"
      invite = EventInvite.find(params[:id])

      if invite.update(status: params[:new_status])
        flash[:notice] = I18n.t("event_invites.success", status: params[:new_status])
      else
        flash[:alert] = I18n.t("event_invites.update_error")
      end
    else
      flash[:alert] = I18n.t("event_invites.pending_error")
    end

    redirect_to home_path
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

    users.map { |user| { user: user, host_event: event } }
  end

  # Ensures that an invite hasn't been revoked and has the correct token.
  def validate_token
    invite = EventInvite.find_by(id: params[:id])

    redirect_to(home_path, alert: t("event_invites.not_found")) && return if invite.nil?
    redirect_to home_path, alert: t("event_invites.no_permission") unless params[:token] == invite.token
  end
end
