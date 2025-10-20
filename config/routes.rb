Rails.application.routes.draw do
  # Health check endpoint
  get '/health', to: proc { [200, {}, ['OK']] }

  namespace :api do
    namespace :v1 do
      # Authentication
      post 'auth/login', to: 'auth#login'
      post 'auth/register', to: 'auth#register'
      get 'auth/me', to: 'auth#me'

      # Agents
      resources :agents do
        member do
          post :execute
        end

        # Conversations nested under agents
        resources :conversations, only: [:index, :create]
      end

      # Conversations
      resources :conversations, only: [:show, :update] do
        member do
          get :messages
          post :messages, to: 'conversations#send_message'
        end
      end
    end
  end
end
