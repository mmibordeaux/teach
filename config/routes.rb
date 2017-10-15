Rails.application.routes.draw do
  resources :jobs
  resources :involvements
  resources :projects
  resources :fields
  resources :objectives
  resources :keywords
  resources :competencies
  get 'teaching_modules/summary' => 'teaching_modules#summary', as: 'teaching_modules_summary'
  get 'teaching_modules/costs' => 'teaching_modules#costs', as: 'teaching_modules_costs'
  resources :teaching_modules
  resources :teaching_categories
  resources :teaching_subjects
  resources :teaching_units
  resources :semesters, only: [:index, :show]
  get 'users/summary' => 'users#summary', as: 'users_summary'
  get 'users/costs' => 'users#costs', as: 'users_costs'
  resources :users
  get 'parse' => 'application#parse'
  root 'dashboard#index'
end
