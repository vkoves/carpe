class EventInvitesController < ApplicationController
  before_action :validate_token, only: [:email_action]

  # Called when clicking the links in an event invite email
  def email_action
    # Do not allow setting status back to pending
    if params[:new_status] != 'pending_response'
      invite = EventInvite.find(params[:id])

      if invite.update(status: params[:new_status])
        flash[:notice] = I18n.t('event_invites.success', status: params[:new_status])
      else
        flash[:alert] = I18n.t('event_invites.update_error')
      end
    else
      flash[:alert] = I18n.t('event_invites.pending_error')
    end

    redirect_to home_path
  end

  private

  # Ensures that an action has the event invite's token specified
  def validate_token
    invite = EventInvite.find(params[:id])

    unless params[:token] == invite.token
      # Token is invalid or empty, no permission to update
      redirect_to home_path, alert: t("event_invites.no_permission")
    end
  end
end
