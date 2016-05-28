Rails.application.routes.draw do
  get "u/:id", to: "users#show", :as => :user
  get "/users", to: "users#index"

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "users/registrations" }

  #General page routes
  get "/home" => 'home#index'
  get "/schedule" => 'schedule#schedule'
  get "/userviewer" => 'pages#userviewer'
  get "/find_friends" => 'users#find_friends'
  get 'pages/schedule'

  #Group Rotes
  get "/groups" => 'groups#index'
  get "/groups/create" => 'groups#create'
  get "/groups/destroy" => 'groups#destroy'
  get "/groups/add-users/:id" => 'groups#add_users'
  get "/group/:id" => 'groups#show', :as => :group
  get "/group/:id/edit" => 'groups#edit'
  post "/group/:id" => 'groups#update'

  #Admin Routes
  get "/promote" => 'pages#promote'
  get "/sandbox" => 'pages#sandbox'
  get "/admin" => 'pages#admin', :as => :admin_panel
  match "/destroy_user/:id" => 'pages#destroy_user', :via => :delete, :as => :admin_destroy_user

  #User Routes
  get "/search_users" => 'users#search'
  post "/deny_friend" => 'friendships#deny'
  post "/confirm_friend" => 'friendships#confirm'

  #Event backend commands
  post "/save_events" => 'schedule#save_events'
  post "/delete_event" => 'schedule#delete_event'

  post "/create_category" => 'schedule#create_category'
  post "/delete_category" => 'schedule#delete_category'

  post "/create_break" => 'schedule#create_exception'

  #Other backend stuff
  post "/read_notifications" => 'notifications#read_all'

  root 'home#index'

  resource :friendships


end
