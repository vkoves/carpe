class HomeController < ApplicationController
  def index
  	@home = true
    if current_user
    	#@upcoming_events = current_user.events.where("date >= ?", DateTime.now).limit(5).order(:date)
    	
    	#get non-repeating events from the next 10 days
    	@upcoming_events = current_user.events.where(:date => DateTime.now.beginning_of_day...DateTime.now.end_of_day + 10.day, :repeat => nil)
    	
      current_user.events.where("repeat IS NOT NULL").each do |rep_event| #get all repeating events
      	@upcoming_events.concat(rep_event.events_in_range(DateTime.now.beginning_of_day, DateTime.now.end_of_day + 10.day))
      end
      
      @upcoming_events = @upcoming_events.sort_by(&:date)
    end
  end
end
