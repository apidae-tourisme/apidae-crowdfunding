Rails.application.routes.draw do
  get 'static/fonts'

  root to: 'static#home'
end
