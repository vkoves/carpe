class EventsController < ApplicationController
  def destroy
    @event = Event.find(params[:id])

    authorize! :destroy, @event
    @event.destroy!

    render plain: "Event deleted."
  end

  def setup_hosting
    event = Event.find(params[:id])
    event.make_host_event! unless event.host_event?

    render event.event_invites
  end

  private

  def create_params
    params.permit(:name, :description, :date, :end_date, :group_id,
                  :category_id, :repeat, :location, :repeat_start, :repeat_end,
                  :location, :privacy, :base_event_id)
  end
end
