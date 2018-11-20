class EventInvitesController < ApplicationController
  # Called when clicking the links in an event invite email
  def email_action
    # Do not allow setting status back to pending
    if params[:new_status] != 'pending_response'
      invite = EventInvite.find(params[:id])

      # Require the invite token
      if params[:token] == invite.token
        if invite.update(status: params[:new_status])
          flash[:notice] = I18n.t('event_invites.success', status: params[:new_status])
        else
          flash[:alert] = I18n.t('event_invites.update_error')
        end
      else
        # Token is invalid or empty, no permission to update
        flash[:alert] = I18n.t('event_invites.no_permission')
      end
    else
      flash[:alert] = I18n.t('event_invites.pending_error')
    end

    redirect_to home_path
  end
end
