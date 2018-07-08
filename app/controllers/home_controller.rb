class HomeController < ApplicationController
  def index
    if current_user
      @home = true
      render 'dashboard'
    else
      render 'home'
    end
  end
end
