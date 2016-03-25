class HomeController < ApplicationController
  def index
  	@home = true
    if current_user
      @upcoming_events = current_user.events_in_range(DateTime.now - 5.day, DateTime.now.end_of_day + 10.day)
      @upcoming_events = @upcoming_events.select{|event| event.date > DateTime.now} #filter out past events
    end
  end
end
