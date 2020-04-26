Rails.application.routes.draw do
  get 'accueil', to: 'static#home'
  get 'souscrire', to: 'subscriptions#new'
  get 'comment-souscrire', to: 'static#howto'
  get 'acteurs-coordinateurs-territoriaux', to: 'static#territories'
  get 'professionnels-prives', to: 'static#companies'
  get 'soutiens-du-reseau', to: 'static#supporters'
  get 'faq', to: 'static#faq'
  get 'contact', to: 'static#contact'
  get 'mentions-legales', to: 'static#legal'

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

  get 'static/fonts'

  mount Sibu::Engine, at: '/', as: 'site_display', constraints: lambda {|req| req.host != Rails.application.config.sibu[:host]}
  mount Sibu::Engine, at: '/administration', constraints: lambda {|req| req.host == Rails.application.config.sibu[:host]}

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

  root to: 'static#home'
end
