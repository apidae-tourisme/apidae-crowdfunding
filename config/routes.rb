Rails.application.routes.draw do
  get 'souscrire', to: 'subscriptions#new'
  get 'comment-souscrire', to: 'subscriptions#howto'
  get 'acteurs-coordinateurs-territoriaux', to: 'static#territories'
  get 'professionnels-prives', to: 'static#companies'
  get 'soutiens-du-reseau', to: 'static#supporters'
  get 'contact', to: 'static#contact'
  get 'mentions-legales', to: 'static#legal'

  get 'static/home'

  resources :subscriptions, only: [:index, :new, :create], path: 'souscriptions' do
    get :confirm, on: :collection, path: 'confirmation'
  end

  get 'static/fonts'

  # root to: 'static#home'
  root to: 'static#temp'
end
