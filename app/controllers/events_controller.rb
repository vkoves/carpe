class EventsController < ApplicationController
  before_action :authorize_signed_in!

  def create
    event = Event.new(event_params)
    authorize! :create, event
    event.save

    render json: event
  end

  def destroy
    event = Event.find(params[:id])
    authorize! :destroy, event
    event.destroy

    render json: event
  end

  private

  def event_params
    params.permit(:name, :description, :date, :end_date, :user_id, :group_id,
                  :category_id, :repeat, :location, :repeat_start, :repeat_end,
                  :location, :privacy, :base_event_id)
  end
end