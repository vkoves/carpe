class EventInvitesController < ApplicationController
  # Called when clicking the links in an event invite email
  def email_action
    # Do not allow setting status back to pending
    if params[:new_status] != 'pending_response'
      invite = EventInvite.find(params[:id])

      # Require the invite token
      if params[:token] == invite.token
        if invite.update(status: params[:new_status])
          flash[:notice] = "We have updated that event invite, you are now marked as \"#{params[:new_status]}\""
        else
          flash[:alert] = "Something went wrong responding to that event invite!"
        end
      else
        flash[:alert] = "You don't have permission to update that event invite!"
      end
    else
      flash[:alert] = "You cannot mark yourself as pending response on an event invite!"
    end

    redirect_to home_path
  end
end
