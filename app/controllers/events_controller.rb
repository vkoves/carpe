class EventsController < ApplicationController
  def destroy
    @event = Event.find(params[:id])

    authorize! :destroy, @event
    @event.destroy!

    render plain: "Event deleted."
  end

  def setup_hosting
    event = Event.find(params[:id])

    unless event.host_event?
      event_invite = event.make_host_event!

      # for demonstration purposes
      Notification.create(sender: current_user, receiver: current_user,
                          event: :event_invite, entity: event_invite)
    end

    render EventInvite.where(event: event)
  end

  private

  def create_params
    params.permit(:name, :description, :date, :end_date, :group_id,
                  :category_id, :repeat, :location, :repeat_start, :repeat_end,
                  :location, :privacy, :base_event_id)
  end
end
