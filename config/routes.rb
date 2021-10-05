Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resource :schedule, only: %i[show]
  resources :assignment_weeks do
    collection do
      post :copy_week
    end
  end
end
