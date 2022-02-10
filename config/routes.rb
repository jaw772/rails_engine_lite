Rails.application.routes.draw do
  get '/api/v1/merchants/find_all', to: 'merchants_find#search_all'
  get '/api/v1/merchants/find', to: 'merchants_find#search_one'
  namespace :api do
    namespace :v1 do
      resources :merchants, only: [:index, :show] do
        resources :items, only: [:index], controller: 'merchant_items'
      end
    end
  end
  get '/api/v1/items/find', to: 'item_find#search_one'
  get '/api/v1/items/find_all', to: 'item_find#search_all'
  namespace :api do
    namespace :v1 do
      resources :items do
        resources :merchant, only: [:index], controller: 'item_merchant'
      end
    end
  end
end
