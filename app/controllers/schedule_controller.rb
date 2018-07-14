#The controller for schedule related pages and actions, such as the schedule page
#as well as creating and editing categories

# TODO: Most requests should enforce user being signed in, as data can't be made anonymously
class ScheduleController < ApplicationController
  after_action :allow_iframe, only: :schedule

  def schedule
    if params[:uid] # user viewing another user's schedule
      @user = User.find(params[:uid])
    else # user viewing their own schedule
      unless user_signed_in?
        redirect_to user_session_path, alert: "You have to be signed in to do that!" and return
      end

      @user = current_user
      @read_only = false
    end

    @embedded = true if params[:iframe]
  end

  def create_category
    if params[:id]
      @cat = Category.find(params[:id])
      authorize! :edit, @cat
    else
      @cat = Category.new
    end

    @cat.color = params[:color]

    @cat.user = current_user
    @cat.group = Group.find(params[:group_id]) if params[:group_id].present?

    @cat.privacy = params[:privacy] if params[:privacy]
    @cat.name = params[:name]

    if params[:breaks]
      @cat.repeat_exceptions = params[:breaks].map { |id| RepeatException.find(id) }
    end

    authorize! :create, @cat
    @cat.save

    render json: @cat
  end

  def delete_category
    category = Category.find(params[:id])
    authorize! :destroy, category
    category.destroy

    render plain: "Category destroyed"
  end

  def create_exception
    if params[:id]
      @exception = RepeatException.find(params[:id])
      authorize! :edit, @exception
    else
      @exception = RepeatException.new
    end

    @exception.name = params[:name] if params[:name]
    @exception.start = Date.parse(params[:start]) if params[:start]
    @exception.end =  Date.parse(params[:end]) if params[:end]
    @exception.user = current_user
    @exception.group = Group.find(params[:group_id]) if params[:group_id].present?
    @exception.save

    render json: @exception.id
  end

  def save_events
    new_event_ids = {}

    unless params[:map]
      render plain: "No events to save!" and return
    end

    params[:map].each do |key, obj|
      if obj["eventId"].present? # if this is an existing item
        evnt = Event.find(obj["eventId"].to_i)
        authorize! :edit, evnt
      else
        evnt = Event.new

        evnt.user = current_user
        evnt.group = Group.find(params[:group_id]) if params[:group_id].present?
      end

      evnt.name = obj["name"]
      evnt.repeat = obj["repeatType"]
      evnt.date = DateTime.parse(obj["startDateTime"])
      evnt.end_date = DateTime.parse(obj["endDateTime"])

      evnt.repeat_start = obj["repeatStart"].blank? ? nil : Date.parse(obj["repeatStart"])
      evnt.repeat_end = obj["repeatEnd"].blank? ? nil : Date.parse(obj["repeatEnd"])

      if obj["breaks"]
        evnt.repeat_exceptions = obj["breaks"].map { |id| RepeatException.find(id) }
      end

      evnt.description = obj["description"] || ""
      evnt.location = obj["location"] || ""
      evnt.category_id = obj["categoryId"].to_i


      authorize! :create, evnt
      evnt.save

      if obj["eventId"].empty? # if this is not an existing event
        new_event_ids[obj["tempId"]] = evnt.id
      end
    end

    render :json => new_event_ids
  end

  def delete_event
    event = Event.find(params[:id])
    authorize! :destroy, event
    event.destroy

    render plain: "Event deleted."
  end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  rescue_from CanCan::AccessDenied do |exception|
    render plain: exception.message, status: :forbidden
  end
end