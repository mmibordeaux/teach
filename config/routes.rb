Rails.application.routes.draw do
  resources :users
  get 'parse' => 'application#parse'
  root 'users#index'
end
