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
  
  def save_events #save events
    text = params.to_s

    params[:map].each do |key, obj|
        if(obj["event_id"])
          evnt = Event.find(obj["event_id"].to_i)
        else
          evnt = Event.new();
        end
        evnt.name = obj["name"]
        evnt.user = current_user
        evnt.date = DateTime.parse(obj["datetime"])
        evnt.category_id = obj["cat_id"].to_i
        evnt.save
    end

    render :text => text
  end
end
