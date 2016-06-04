#The controller for schedule related pages and actions, such as the schedule page
#as well as creating and editing categories
class ScheduleController < ApplicationController
  after_action :allow_iframe, only: :schedule

  def schedule
    if params[:uid] #if a uid was passed, show that schedule in read only mode
      @user = User.find(params[:uid])
      @read_only = true
    elsif current_user #if the user is logged in, show their schedule
      @user = current_user
    else
      redirect_to user_session_path;
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
    
    if(params[:user_id])
      @cat.user = User.find(params[:user_id])
    end
    
    if(params[:privacy])
      @cat.privacy = params[:privacy]
    end

    @cat.name = params[:name]
    
    @cat.repeat_exceptions.clear #empty out
    puts params
    if params[:breaks]
      params[:breaks].each do |break_id| #then add the current things
        @cat.repeat_exceptions << RepeatException.find(break_id)
      end
    end

    @cat.save
    render json: @cat
  end

  def delete_category
    Category.destroy(params[:id])
    render :text => "Category destroyed"
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

  def save_events #save events
    text = params.to_s
    new_event_ids = {}

    unless params[:map] #if there is no map param defined
      render :text => "No events to save!" and return #say so and return
    end

    params[:map].each do |key, obj|
        unless obj["eventId"].empty? #if this is an existing item
          evnt = Event.find(obj["eventId"].to_i)
        else
          evnt = Event.new()
        end
        evnt.name = obj["name"]
        evnt.user = current_user
        evnt.repeat = obj["repeatType"]
        evnt.date = DateTime.parse(obj["startDateTime"])
        evnt.end_date = DateTime.parse(obj["endDateTime"])

        if obj["repeatStart"]
          evnt.repeat_start = Date.parse(obj["repeatStart"])
        end
        if obj["repeatEnd"]
          evnt.repeat_end = Date.parse(obj["repeatEnd"])
        end

        evnt.repeat_exceptions.clear #empty out
        if obj["breaks"]
          obj["breaks"].each do |break_id| #then add the current things
            evnt.repeat_exceptions << RepeatException.find(break_id)
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

  def delete_event #delete events
    Event.destroy(params[:id])
    render :text => "Event deleted."
  end
end