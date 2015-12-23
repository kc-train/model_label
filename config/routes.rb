ModelLabel::Engine.routes.draw do
  root 'home#index'

  resources :labels
end