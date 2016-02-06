class HomeController < ApplicationController
  def index
  	@home = true
    if current_user
    	@upcoming_events = current_user.events.where("date >= ?", DateTime.now).limit(5).order(:date)
    end
  end
end
