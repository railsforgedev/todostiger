Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  resources :todos do
    collection do
      get 'by_date'
    end
    member do
      patch :toggle_status
    end
  end
  # Routes for date navigation
  get 'todos/date/:date', to: 'todos#by_date', as: :todos_by_date
  # Set root path
  root 'todos#index'
end
