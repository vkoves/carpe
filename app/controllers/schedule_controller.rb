#The controller for schedule related pages and actions, such as the schedule page
#as well as creating and editing categories
#
# TODO: Most requests should enforce user being signed in, as data can't be made anonymously
class ScheduleController < ApplicationController
  after_action :allow_iframe, only: :schedule

  def schedule
    if params[:uid] #if a uid was passed, show that schedule in read only mode
      @user = User.find(params[:uid])
      @read_only = true
    else #show their schedule
      authorize_signed_in! and return unless user_signed_in?
      @user = current_user
    end

    if params[:iframe] #if iframe
      @holderClass = "iframe" #indicate with the holder class
      @read_only = true #and force read_only no matter what
    end
  end

  def create_category
    if params[:id]
      @cat = Category.find(params[:id])
    else
      @cat = Category.new
    end

    @cat.color = params[:color]

    unless params[:group_id].empty?
      @cat.group = Group.find(params[:group_id])
    end

    if(params[:user_id])
      @cat.user = User.find(params[:user_id])
    end

    if(params[:privacy])
      @cat.privacy = params[:privacy]
    end

    @cat.name = params[:name]

    @cat.repeat_exceptions.clear #empty out
    if params[:breaks]
      params[:breaks].each do |break_id| #then add the current things
        @cat.repeat_exceptions << RepeatException.find(break_id)
      end
    end

    @cat.save
    render json: @cat
  end

  ###
  # Authenticated
  # Verifies the user deleting is the owner
  ###
  def delete_category
    category = Category.find(params[:id])
    if current_user and (category.user == current_user or category.group.in_group?(current_user)) #if user is owner or in owning group
      Category.destroy(params[:id])
      render plain: "Category destroyed"
    end
  end

  def create_exception #ccreate a repeat exception
    if params[:id]
      @exception = RepeatException.find(params[:id])
    else
      @exception = RepeatException.new
    end

    @exception.name = params[:name] if params[:name]
    @exception.start = Date.parse(params[:start]) if params[:start]
    @exception.end =  Date.parse(params[:end]) if params[:end]
    @exception.user = current_user
    @exception.save
    render json: @exception.id #return the id of the repeat exception
  end

  ###
  # Authenticated
  # Verifies the user changing events is the owner
  ###
  def save_events #save events
    text = params.to_s
    new_event_ids = {}

    unless params[:map] #if there is no map param defined
      render plain: "No events to save!" and return #say so and return
    end

    params[:map].each do |key, obj|
        unless obj["eventId"].empty? #if this is an existing item
          evnt = Event.find(obj["eventId"].to_i)

          # If a user tries to edit an event they don't own, cancel the request
          unless current_user == evnt.user or (evnt.group and evnt.group.in_group?(current_user)) # TODO: Make an event helper for whether the user can change the event
            render :text => "You don't have permission to change this event!", :status => :forbidden and return
          end
        else
          evnt = Event.new()
          evnt.user = current_user
        end

        evnt.name = obj["name"]
        unless params[:group_id].empty?
          evnt.group = Group.find(params[:group_id]) # TODO: Do we need to find the group for this?
        end
        evnt.repeat = obj["repeatType"]
        evnt.date = DateTime.parse(obj["startDateTime"])
        evnt.end_date = DateTime.parse(obj["endDateTime"])

        if obj["repeatStart"].blank?
          evnt.repeat_start = nil
        else # make sure it's not nil or an empty string
          evnt.repeat_start = Date.parse(obj["repeatStart"])
        end
        if obj["repeatEnd"].blank?
          evnt.repeat_end = nil
        else # make sure it's not nil or an empty string
          evnt.repeat_end = Date.parse(obj["repeatEnd"])
        end

        evnt.repeat_exceptions.clear #empty out
        if obj["breaks"]
          obj["breaks"].each do |break_id| #then add the current things
            evnt.repeat_exceptions << RepeatException.find(break_id) # TODO: Do we need to find the repeat exceptions for this?
          end
        end

        evnt.description = obj["description"] || ""
        evnt.location = obj["location"] || ""
        evnt.category_id = obj["categoryId"].to_i
        evnt.save

        if obj["eventId"].empty? #if this is not an existing event
          new_event_ids[obj["tempId"]] = evnt.id
        end
    end

    render :json => new_event_ids
    #render :json => params[:map] #useful for seeing what data was passed
  end

  ###
  # Authenticated
  # Verifies the user changing events is the owner
  ###
  def delete_event #delete events
    event = Event.find(params[:id])
    if current_user and (event.user == current_user or event.group.in_group?(current_user)) #if the current user is the owner or in the owner group
      Event.destroy(params[:id])
      render plain: "Event deleted."
    end
  end

  def event_participants
    participants = EventInvite.where(event_id: params[:id])
    render participants
  end

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end