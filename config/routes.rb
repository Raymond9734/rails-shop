Rails.application.routes.draw do
  resources :mpesas
  resources :products
  devise_for :users, controllers: {
    registrations: 'registrations'
  }
  root 'products#index'
  resources :carts
  resources :line_items, only: [:show, :create, :update, :destroy]
  post 'stkpush', to: 'mpesas#stkpush'
  post 'stkquery', to: 'mpesas#stkquery'
  # # Payment routes
  # scope '/checkout' do
  #   get '/mpesa', to: 'payments#mpesa_checkout', as: 'mpesa_checkout'
  #   post '/mpesa/process', to: 'payments#process_mpesa_payment', as: 'process_mpesa_payment'
  #   get '/mpesa/status', to: 'payments#payment_status', as: 'payment_status'
  # end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/mpesa', to: 'payments#mpesa_checkout', as: 'mpesa_checkout'
end
