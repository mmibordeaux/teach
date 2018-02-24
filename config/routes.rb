Rails.application.routes.draw do
  resources :promotions
  devise_for :users
  get 'teaching_modules/summary' => 'teaching_modules#summary', as: 'teaching_modules_summary'
  get 'users/summary' => 'users#summary', as: 'users_summary'
  post 'users/:id/reset' => 'users#reset', as: 'reset_user'
  get 'budgets/users' => 'budgets#users', as: 'budgets_users'
  get 'budgets/teaching_modules' => 'budgets#teaching_modules', as: 'budgets_teaching_modules'
  # get 'parse' => 'application#parse'
  resources :users, :jobs, :involvements, :projects, :fields, :objectives, :keywords, :competencies, :teaching_modules, :teaching_categories, :teaching_subjects, :teaching_units
  resources :semesters, only: [:index, :show]
  root 'dashboard#index'
end
