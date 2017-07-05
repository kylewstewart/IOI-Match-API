Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :principals, only: [:index] do
        resources :sponsors, only: [:index]
        resources :iois, only: [:index, :create]
        get '/negotations' => 'negotations#principals_index'
        # get '/sponsorships' => 'sponsorships#principals_index'
        # get '/negotations/:id' => 'negotations#principals_show'
        # get '/pct_traded' => 'pct_traded#principals_index'
        # resources :negotations, only: [:show]
      end

      # resources :agents, only: [:index] do
      #   resources :satisfaction, only: [:index]
      #   get '/pct_traded' => 'pct_traded#agents_index'
      #   get '/sponsorships' => 'sponsorships#agents_index'
      #   get '/negotations' => 'negotations#agents_index'
      # end

      resources :stocks, only: [:index]
      resources :iois, only: [:destroy,:update]

    end
  end

end
