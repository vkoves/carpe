class EventsController < ApplicationController
  before_action :authorize_signed_in!
  respond_to :json

  def create
    event = Event.create(event_params)
    render json: event
  end

  def destroy
    event = Event.find(params[:id])
    event.destroy
    render json: event.errors
  end

  private

  def event_params
    params.permit(:name, :description, :date, :end_date, :user_id, :group_id,
                  :category_id, :repeat, :location, :repeat_start, :repeat_end,
                  :location, :privacy, :base_event_id)
  end
end