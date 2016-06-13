Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources 'weekly_lists', only: [:show]
  get 'new_releases', to: 'weekly_lists#new_releases'
  root 'weekly_lists#new_releases'
end
