Rails.application.routes.draw do
  devise_for :users
  get 'users/summary' => 'users#summary', as: 'users_summary'
  post 'users/:id/reset' => 'users#reset', as: 'reset_user'
  get 'budgets/users' => 'budgets#users', as: 'budgets_users'
  get 'budgets/teaching_modules' => 'budgets#teaching_modules', as: 'budgets_teaching_modules'
  # get 'parse' => 'application#parse'
  resources :users, :jobs, :involvements, :projects, :fields, :objectives, :keywords, :competencies, :teaching_modules, :teaching_categories, :teaching_subjects, :teaching_units, :promotions
  resources :semesters, only: [:index, :show]
  resources :years, only: [:index, :show] do 
    get 'users/:id' => 'years#user', as: :user
    get 'semesters/:id' => 'semesters#show_in_year', as: :semester
  end
  get 'dashboard' => 'dashboard#index', as: :dashboard
  scope :discuss do 
    get ':year' => 'discuss#year', as: :discuss_year
    get ':year/:project_id' => 'discuss#project', as: :discuss_project
  end
  scope :api do
    get 'promotions/:year' => 'api#promotion'
  end
  root 'discuss#index'
end
