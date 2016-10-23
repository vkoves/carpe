class HomeController < ApplicationController
  def index
    if current_user
      @home = true
      @upcoming_events = current_user.events_in_range(DateTime.now - 5.day, DateTime.now.end_of_day + 10.day)
      @upcoming_events = @upcoming_events.select{|event| event.end_date > DateTime.now} #filter out past events
      render 'dashboard'
    else
      render 'home'
    end
  end
end
