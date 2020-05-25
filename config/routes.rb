Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'api/v1/auth', controllers: {
    registrations: 'registrations',
    sessions: 'sessions',
    passwords: 'passwords'
  }

  apipie
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount Sidekiq::Web => '/sidekiq'



  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :payments, defaults: { format: :html } do
        collection do
          match '/callback' => 'payments#callback', via: [:get, :post]
        end
      end


      devise_scope :user do
        post 'omniauth/:provider', to: 'omniauth#create', as: :omniauth
      end

      resources :product_types, only: :index
      resources :items, except: [:new, :edit] do
        get :seller_items, on: :collection
        get :last_item, on: :collection
        get :preorder_items, on: :collection
      end

      post 'push_notification', to: 'push_notifications#index'
      get 'reset_push_count', to: 'push_notifications#reset'

      resources :users, only: [:show] do
        resources :reviews, only: [:index, :create, :show]
      end

      resources :addresses, only: [:index, :create]

      resources :orders, except: [:destroy, :update] do
        member do
          get :change_status
          get :cancel
        end
        collection do
          get :waiting_for_driver
          post :calculate
        end
      end
    end
  end
end
