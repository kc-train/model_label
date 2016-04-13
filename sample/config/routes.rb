Rails.application.routes.draw do
  ModelLabel::Routing.mount '/', :as => 'model_label'
  mount PlayAuth::Engine => '/auth', :as => :auth

  root to: 'home#index'
end
