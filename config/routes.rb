Rails.application.routes.draw do
  get "u/:id", to: "users#show"
  get "/users", to: "users#index"
   
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  get 'pages/schedule'

  get 'shared/_header'

  get "/home" => 'home#index'
  get "/schedule" => 'pages#schedule'
  get "/userviewer" => 'pages#userviewer'
  get "/catviewer" => 'pages#catviewer'

  root 'home#index'
  
  resource :friendships

	
end
