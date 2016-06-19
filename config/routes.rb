Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'new_releases', to: 'weekly_lists#new_releases'
  get 'releases/:date', to: 'weekly_lists#show'
  root 'weekly_lists#new_releases'
end
