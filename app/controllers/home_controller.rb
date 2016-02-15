class HomeController < ApplicationController
  def index
  	@home = true
    if current_user
      @upcoming_events = current_user.events_in_range(DateTime.now, DateTime.now.end_of_day + 10.day)
    end
  end
end
