Rails.application.routes.draw do
  devise_for :users
  match "/delayed_job" => DelayedJobWeb, anchor: false, via: [:get, :post]
  get 'users/summary' => 'users#summary', as: 'users_summary'
  post 'users/:id/reset' => 'users#reset', as: 'reset_user'
  get 'budgets/users' => 'budgets#users', as: 'budgets_users'
  get 'budgets/teaching_modules' => 'budgets#teaching_modules', as: 'budgets_teaching_modules'
  # get 'parse' => 'application#parse'
  resources :users, :jobs, :fields, :objectives, :keywords, :competencies, :teaching_modules, :teaching_categories, :teaching_subjects, :teaching_units
  resources :semesters, only: [:index, :show]
  resources :years, only: [:index, :show] do 
    resources :projects, module: :years
    resources :involvements, module: :years
    resources :semesters, module: :years, only: [:index, :show]
    resources :teaching_modules, module: :years, only: [:index, :show]
    resources :users, module: :years
  end
  resources :promotions do 
    resources :projects, module: :promotions, only: :index
    resources :teaching_modules, module: :promotions, only: :index
    get :events
    get :events_imported
    post :events_sync
  end
  get 'dashboard' => 'dashboard#index', as: :dashboard
  scope :discuss do 
    get ':year' => 'discuss#year', as: :discuss_year
    get ':year/:project_id' => 'discuss#project', as: :discuss_project
  end
  scope :api do
    get '' =>  'api#index'
    get 'promotions' => 'api#promotions'
    get 'promotions/:year' => 'api#promotion', as: :api_promotion
  end
  root 'discuss#index'
end
