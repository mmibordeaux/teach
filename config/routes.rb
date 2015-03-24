Rails.application.routes.draw do
  resources :keywords

  resources :competencies

  resources :teaching_modules

  resources :teaching_categories

  resources :teaching_subjects

  resources :teaching_units

  resources :semesters

  resources :users
  get 'parse' => 'application#parse'
  root 'users#index'
end
