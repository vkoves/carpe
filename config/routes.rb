Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :omniauth_callbacks => "omniauth_callbacks",
    :registrations => "users/registrations"
  }

  resources :users, only: [:index, :destroy, :show] do
    get :promote, :demote, :inspect, on: :member
  end

  resources :relationships

  namespace :schedule do
    post :save_events
  end

  resources :categories, only: [:create, :update, :destroy]
  resources :repeat_exceptions, only: [:create, :update, :destroy]

  resources :events, only: [:create, :destroy] do
    resources :event_invites, except: [:edit, :new], shallow: true, as: :invites do
      post :setup, on: :collection
    end
  end

  namespace :search do
    get :all, :users, :event_invite_participants
  end

  #General page routes
  get "/home" => 'home#index', :as => :home
  get "/schedule" => 'schedule#schedule'
  get "/userviewer" => 'pages#userviewer'

  get "/about" => 'pages#about'
  get "/status" => 'pages#status'

  #Group Rotes
  get "/groups" => 'groups#index'
  get "/groups/create" => 'groups#create'
  get "/groups/destroy" => 'groups#destroy'
  get "/groups/add-users/:id" => 'groups#add_users'
  get "/group/:id" => 'groups#show', :as => :group
  get "/group/:id/edit" => 'groups#edit'
  post "/group/:id" => 'groups#update'

  #Admin Routes
  get "/sandbox" => 'pages#sandbox'
  get "/admin" => 'pages#admin', :as => :admin_panel
  post "/run_command" => 'pages#run_command'
  post "/check_if_command_is_finished" => 'pages#check_if_command_is_finished'

  #Other backend stuff
  post "/read_notifications" => 'notifications#read_all'
  post "/notification_updated/:id(/:response)" => 'notifications#updated', as: :notification_updated

  root 'home#index'

end
