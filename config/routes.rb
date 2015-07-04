Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  get 'pages/schedule'

  get 'shared/_header'

  get "/home" => 'home#index'
  get "/schedule" => 'pages#schedule'

  root 'home#index'

	
end
