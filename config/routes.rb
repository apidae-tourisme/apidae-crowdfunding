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

  devise_for :users, path: 'administration', controllers: {omniauth_callbacks: 'users/omniauth_callbacks'},
             path_names: {sign_in: 'connexion', sign_out: 'deconnexion'}

  authenticated :user do
    get 'administration' => 'admin/subscriptions#index'
  end

  scope module: 'admin' do
    scope '/administration' do
      resources :subscriptions, only: [:index] do
        get :export, on: :collection
      end
    end
  end

  root to: 'static#home'
end
