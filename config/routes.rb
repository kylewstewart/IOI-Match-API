Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :principals, only: [:index] do
        resources :sponsors, only: [:index]
        resources :iois, only: [:index, :create]
        get '/negotiations' => 'negotiations#principals_index'
      end

      resources :agents, only: [:index] do
        resources :sponsorships, only: [:index]
        get '/negotiations' => 'negotiations#agents_index'
      end

      resources :stocks, only: [:index]
      resources :iois, only: [:destroy, :update]

      resources :negotiations, only: [:update] do
        resources :negotiation_principals, only: [:index]
        resources :principals, only: [] do
          get 'negotiation_principals' => 'negotiation_principals#show'
          patch 'negotiation_principals' => 'negotiation_principals#update_rating'
        end
      end

      patch '/negotiation_principals/:id' => 'negotiation_principals#update_traded'
      get '/match_stocks' => 'algo#match_stocks'
      get '/match/:id' => 'algo#match'
      post '/common' => 'algo#common'

    end
  end

end
