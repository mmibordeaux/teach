Rails.application.routes.draw do
  resources :models

  resources :jobs

  resources :involvements
  resources :projects
  resources :fields
  resources :objectives
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
