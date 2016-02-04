class HomeController < ApplicationController
  def index
  	@home = true
  	week_later = DateTime.now + 14
  	@upcoming_events = current_user.events.where("date >= ?", DateTime.now).limit(5).order(:date)
  end
end
