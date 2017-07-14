Rails.application.routes.draw do
  resources :categories

  get "u/:id_or_url(/:page)", to: "users#show", :as => :user
  get "/users", to: "users#index"

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "users/registrations" }

  #General page routes
  get "/home" => 'home#index', :as => :home
  get "/schedule" => 'schedule#schedule'
  get "/userviewer" => 'pages#userviewer'
  get "/group" => 'groups#index'
  get "/about" => 'pages#about'
  get "/status" => 'pages#status'

  #Follow Routes
  resources :relationships

  # Group Routes
  resources :groups
  get "/groups/add-users/:id" => 'groups#add_users', as: :group_add_user

  #Admin Routes
  get "/promote" => 'pages#promote'
  get "/sandbox" => 'pages#sandbox'
  get "/admin" => 'pages#admin', :as => :admin_panel
  match "/destroy_user/:id" => 'pages#destroy_user', :via => :delete, :as => :admin_destroy_user
  get "/admin_user_info/:id" => 'pages#admin_user_info', :as => :admin_user_info

  #User Routes
  get "/search_users" => 'users#search'
  get "/search_core" => 'application#search_core'
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

end
