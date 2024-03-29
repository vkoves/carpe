# The controller for schedule related pages and actions, such as the schedule page
# as well as creating and editing categories

# TODO: Most requests should enforce user being signed in, as data can't be made anonymously
class SchedulesController < ApplicationController
  # Only admins can access the beta scheduler
  before_action :authorize_admin!, only: [:show_beta]

  after_action :allow_iframe, only: :show

  def show
    if params[:uid] # user viewing another user's schedule
      @user = User.find(params[:uid])
    else # user viewing their own schedule
      redirect_to(user_session_path, alert: "You have to be signed in to do that!") && return unless user_signed_in?

      @user = current_user
      @read_only = false
    end

    @embedded = true if params[:iframe]
  end

  def save
    new_event_ids = {}

    params[:events].each do |obj|
      # If an event ID is passed, this event is already in the DB and exists
      existing_event = obj["eventId"].present?

      if existing_event
        evnt = Event.find(obj["eventId"].to_i)
      else
        evnt = Event.new

        evnt.user = current_user
        evnt.group = Group.find(obj["groupId"]) if obj["groupId"].present?
      end

      evnt.name = obj["name"]
      evnt.repeat = obj["repeatType"]
      evnt.date = Time.find_zone("UTC").parse(obj["startDateTime"])
      evnt.end_date = Time.find_zone("UTC").parse(obj["endDateTime"])

      evnt.repeat_start = obj["repeatStart"].blank? ? nil : Date.parse(obj["repeatStart"])
      evnt.repeat_end = obj["repeatEnd"].blank? ? nil : Date.parse(obj["repeatEnd"])

      evnt.repeat_exceptions = obj["breaks"].map { |id| RepeatException.find(id) } if obj["breaks"]

      evnt.description = obj["description"] || ""
      evnt.location = obj["location"] || ""
      evnt.category_id = obj["categoryId"].to_i

      if existing_event
        authorize! :edit, evnt
      else
        authorize! :create, evnt
      end

      evnt.save!

      new_event_ids[obj["tempId"]] = evnt.id if obj["eventId"].blank? # if this is not an existing event
    end

    render json: new_event_ids
  end

  private

  # Allow any site to embed this page in an <iframe>
  def allow_iframe
    response.headers["X-Frame-Options"] = "ALLOWALL"
  end
end
