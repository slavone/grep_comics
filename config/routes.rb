Rails.application.routes.draw do
  root 'static_pages#landing'
  get 'new_releases', to: 'weekly_lists#new_releases'
  get 'releases/:date', to: 'weekly_lists#show'
  resources :creators, only: [:index, :show]
  resources :comics, only: :show
  resources :publishers, only: :index

  get :api, to: 'static_pages#api_doc'
  get :about, to: 'static_pages#about'
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
