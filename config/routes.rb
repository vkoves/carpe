Rails.application.routes.draw do
  resources :categories

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "users/registrations" }
  resources :users, only: [:index, :destroy, :show] do
    member do
      get "promote"
      get "demote"
      get "inspect"
    end

    collection do
      get "search"
    end
  end

  #General page routes
  get "/home" => 'home#index', :as => :home
  get "/schedule" => 'schedule#schedule'
  get "/userviewer" => 'pages#userviewer'
  get "/about" => 'pages#about'
  get "/status" => 'pages#status'

  #Follow Routes
  resources :relationships

  #Group Routes
  resources :groups
  resources :user_groups, only: [:create, :update, :destroy]
  post "/invite_to_group", to: 'user_groups#invite_to_group', as: :invite_to_group
  get "join_group/:id", to: 'groups#join', as: :join_group
  get "leave_group/:id", to: 'groups#leave', as: :leave_group

  #Admin Routes
  get "/sandbox" => 'pages#sandbox'
  get "/admin" => 'pages#admin', :as => :admin_panel
  post "/run_command" => 'pages#run_command'
  post "/check_if_command_is_finished" => 'pages#check_if_command_is_finished'

  #User Routes
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
  post "/notification_updated/:id(/:response)" => 'notifications#updated', as: :notification_updated
  get "/search/group/:id/invite_users", to: 'groups#invite_users_search', as: :group_invite_users_search

  root 'home#index'

end
