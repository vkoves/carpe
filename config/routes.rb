Rails.application.routes.draw do
  get "u/:id", to: "users#show"
  get "/users", to: "users#index"
   
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "users/registrations" }

  get 'pages/schedule'

  get 'shared/_header'

  get "/home" => 'home#index'
  get "/schedule" => 'pages#schedule'
  get "/userviewer" => 'pages#userviewer'
  get "/find_friends" => 'users#find_friends'
  
  get "/promote" => 'pages#promote'
  
  get "/admin" => 'pages#admin'
  
  get "/search_users" => 'users#search'
  post "/deny_friend" => 'friendships#deny'
  post "/confirm_friend" => 'friendships#confirm'
  
  #Event backend commands
  post "/save_events" => 'pages#save_events'
  post "/delete_event" => 'pages#delete_event'
  
  post "/create_category" => 'pages#create_category'
  post "/delete_category" => 'pages#delete_category'
  
  root 'home#index'
  
  resource :friendships

	
end
