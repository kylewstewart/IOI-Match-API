Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      resources :principals, only: [:create, :update] do
        get '/sponserships' => 'sponserships#principals_index'
        get '/negotations' => 'negotations#principals_index'
        get '/negotations/:id' => 'negotations#principals_show'
        resources :negotations, only: [:show]
        # resources :iois, only: [:index, :create, :show, :update, :destroy]
      end

      resources :agents, only: [:index] do
        resources :satisfactions, only: [:index]
        get '/sponserships' => 'sponserships#agents_index'
        get '/negotations' => 'negotations#agents_index'
      end

    end
  end

end
