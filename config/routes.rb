Rails.application.routes.draw do
  get 'souscrire', to: 'subscriptions#new'
  get 'static/home'
  get 'mentions-legales', to: 'static#legal'
  get 'contact', to: 'static#contact'

  resources :subscriptions, only: [:index, :new, :create], path: 'souscriptions' do
    get :confirm, on: :collection, path: 'confirmation'
  end

  get 'static/fonts'

  # root to: 'static#home'
  root to: 'static#temp'
end
