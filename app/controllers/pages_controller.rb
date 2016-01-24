class PagesController < ApplicationController
  def schedule
    if current_user
      @user = current_user
      
      if params[:new] == "t"
        newCat = Category.new
        newCat.user = current_user #set the user to the logged in user
        newCat.color = params[:col]
        newCat.name = params[:name]
        newCat.save
        redirect_to "/schedule"
      elsif params[:dest] == "t"
        id = params[:id]
        Category.find_by_id(id).destroy
        redirect_to "/schedule"
      elsif params[:edit] == "t"
        id = params[:id]
        name = params[:name]
        col = params[:col]
        findCat = Category.find_by_id(id)
        findCat.name = name
        findCat.color = col
        findCat.save  
        redirect_to "/schedule"
      elsif params[:clearAll] == "t"
        Category.all.each_with_index do |cat, index|
          cat.destroy
        end
        redirect_to "/schedule"
      end 
    else 
      redirect_to user_session_path;
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
    @cat.save
    render json: @cat
  end
  
  def delete_category
    Category.find(params[:id]).destroy
    render :text => "Category destroyed"
  end
  
  def save_events #save events
    text = params.to_s

    unless params[:map] #if there is no map param defined
      render :text => "No events to save!" and return #say so and return
    end
    
    params[:map].each do |key, obj|
        if(obj["event_id"])
          evnt = Event.find(obj["event_id"].to_i)
        else
          evnt = Event.new();
        end
        evnt.name = obj["name"] 
        evnt.user = current_user
        evnt.repeat = obj["repeat"]
        evnt.date = DateTime.parse(obj["datetime"])
        evnt.end_date = DateTime.parse(obj["enddatetime"])
        @t = obj["enddatetime"]
        @s = obj["datetime"]
        evnt.category_id = obj["cat_id"].to_i
        evnt.save
    end

    render :text => "\"" + @t + "\"  | \"" + @s
  end
  
  def delete_event #delete events
    event = Event.find(params[:id])
    event.destroy
    event.save
    
    render :text => "Event deleted."
  end
  
  def promote
    @user = User.find(params[:id])
    if(current_user and current_user.admin)
      if params[:de] == "true" #if demoting
        @user.admin = false
      else
        @user.admin = true
      end
      @user.save
    end
    redirect_to "/users"
  end
  
  def admin
    if !current_user or !current_user.admin
      redirect_to "/"
    end
  end
end
