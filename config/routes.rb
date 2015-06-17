Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :clear_sale_settings, only: [:show, :edit, :update]

    resources :orders, except: [:show] do
      get 'payments/clear_sale', to: 'payments#clear_sale'
    end
  end
end
