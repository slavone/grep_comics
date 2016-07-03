Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'new_releases', to: 'weekly_lists#new_releases'
  get 'releases/:date', to: 'weekly_lists#show'
  resources :creators, only: [:index, :show]
  resources :comics, only: :show
  resources :publishers, only: :index
  root 'weekly_lists#new_releases'

  get :api, to: 'static_pages#api_doc'
  namespace :api do
    namespace :v1 do
      get :weekly_releases, to: "comics#weekly_releases"
      resources :comics, only: [:index]
      resources :publishers, only: [:index]
      resources :creators, only: [:index]
      get :creator, to: "creators#show"
    end
  end
end
