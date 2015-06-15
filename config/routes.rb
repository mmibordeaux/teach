Rails.application.routes.draw do
  resources :jobs
  resources :involvements
  resources :projects
  resources :fields
  resources :objectives
  resources :keywords
  resources :competencies
  get 'teaching_modules/summary' => 'teaching_modules#summary'
  resources :teaching_modules
  resources :teaching_categories
  resources :teaching_subjects
  resources :teaching_units
  resources :semesters
  resources :users
  get 'parse' => 'application#parse'
  root 'fields#index'
end
