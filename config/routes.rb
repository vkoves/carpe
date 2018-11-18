Rails.application.routes.draw do
  resources :categories

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks", :registrations => "users/registrations" }
  resources :users, only: [:index, :destroy, :show] do
    member do
      get "promote"
      get "demote"
      get "inspect"
    end
  end

  #General page routes
  get "/home" => 'home#index', :as => :home
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
  post "/deny_friend" => 'friendships#deny'
  post "/confirm_friend" => 'friendships#confirm'

  #Event backend commands
  resources :events, only: [:destroy] do
    post :setup_hosting, on: :member
  end

  resources :categories, only: [:create, :update, :destroy]
  resources :repeat_exceptions, only: [:create, :update, :destroy]

  resource :schedule, only: [:show] do
    post :save
  end


  resources :notifications, only: [:destroy] do
    post "update(/:response)", to: "notifications#updated", as: :update, on: :member
    post :read, on: :collection
  end

  resource :search, only: [] do
    get :all, :users, :group_invitable_users
  end

  root 'home#index'

end
