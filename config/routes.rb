Rails.application.routes.draw do
  get 'accueil', to: 'static#home'
  get 'souscrire', to: 'subscriptions#new'
  get 'comment-souscrire', to: 'static#howto'
  get 'acteurs-coordinateurs-territoriaux', to: 'static#territories'
  get 'professionnels-prives', to: 'static#companies'
  get 'soutiens-du-reseau', to: 'static#supporters'
  get 'contact', to: 'static#contact'
  get 'mentions-legales', to: 'static#legal'

  resources :subscriptions, only: [:index, :new, :create, :update, :show], path: 'souscriptions' do
    get :confirm, on: :member, path: 'confirmation'
    get :members, on: :collection
    get :rankings, on: :collection
    get :proportions, on: :collection
    get :regions, on: :collection
    get :share, on: :member, path: 'partager'
    get :widget, on: :member
  end

  get 'static/fonts'

  root to: 'static#home'
end
