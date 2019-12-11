Rails.application.routes.draw do
  get 'souscrire', to: 'subscriptions#new'
  get 'static/fonts'
  get 'static/home'

  resources :subscriptions, only: [:index, :new, :create]

  # root to: 'static#home'
  root to: 'static#temp'
end
