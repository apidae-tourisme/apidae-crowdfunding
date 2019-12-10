Rails.application.routes.draw do
  get 'static/fonts'
  get 'static/home'

  # root to: 'static#home'
  root to: 'static#temp'
end
