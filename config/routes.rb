Rails.application.routes.draw do
  root "home#index"

  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks",
    registrations: "users/registrations"
  }

  resources :users, only: [:index, :destroy, :show] do
    get :promote, :demote, :inspect, on: :member
  end

  resources :relationships, only: [:create, :destroy]
  resources :categories, only: [:create, :update, :destroy]
  resources :repeat_exceptions, only: [:create, :update, :destroy]
  resources :events, only: [:create, :destroy]
  resources :user_groups, only: [:create, :update, :destroy]

  post :group_invite, controller: :groups
  resources :groups do
    get :join, :leave, on: :member
  end

  resources :notifications, controller: :notifications, only: [:destroy] do
    post "update(/:response)", to: "notifications#update", as: :update, on: :member
    post :read, on: :collection
  end

  resource :schedule, only: [:show] do
    post :save
  end

  resource :search, only: [] do
    get :all, :users, :group_invitable_users
  end

  resource :page, only: [], path: '' do
    get :sandbox, :admin, :userviewer, :about, :status
  end

  post :run_command, controller: :pages
  post :check_if_command_is_finished, controller: :pages
end
