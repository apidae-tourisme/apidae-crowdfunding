Rails.application.routes.draw do

  get 'souscrire', to: 'subscriptions#new'
  get 'comment-souscrire', to: redirect('static#howto')

  resources :subscriptions, only: [:index, :new, :create, :edit, :update, :show], path: 'souscriptions' do
    get :confirm, on: :member, path: 'confirmation'
    get :document, on: :member, path: 'bulletin'
    get :members, on: :collection
    get :member, on: :collection
    get :rankings, on: :collection
    get :proportions, on: :collection
    get :regions, on: :collection
    get :share, on: :member, path: 'partager'
    get :widget, on: :member
    patch :update_widget, on: :member
  end

  devise_for :users, path: 'administration', controllers: {omniauth_callbacks: 'users/omniauth_callbacks'},
             path_names: {sign_in: 'connexion', sign_out: 'deconnexion'}

  scope module: 'admin' do
    scope '/administration' do
      resources :subscriptions, only: [:index, :update], path: 'souscriptions', as: 'subs' do
        get :sync_crm, on: :member
        post :send_mail, on: :member
      end
    end
  end

  mount Sibu::Engine, at: '/'

  root to: redirect('/404.html')
end
