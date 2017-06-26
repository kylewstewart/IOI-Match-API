Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do

      # resources :principals, only: [:index]

      resources :principals, only: [:create, :update] do
        resources :sponserships, only: [:index, :create, :show, :update, :destroy]
        resources :negotations, only: [:index, :update]
        resources :iois, only: [:index, :create, :show, :update, :destroy]
      end

      resources :agents, only: [:index] do
        resources :sponserships, only: [:index]

      end

    end
  end

end
