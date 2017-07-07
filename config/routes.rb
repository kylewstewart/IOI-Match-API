Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :principals, only: [:index] do
        resources :sponsors, only: [:index]
        resources :iois, only: [:index, :create]
        get '/negotations' => 'negotations#principals_index'
      end

      resources :agents, only: [:index] do
        resources :sponsorships, only: [:index]
        get '/negotations' => 'negotations#agents_index'
      end

      resources :stocks, only: [:index]
      resources :iois, only: [:destroy,:update]

      resources :negotiations, only: [] do
        get '/principals' => 'principals#negotiation_principals'
      end

    end
  end

end
