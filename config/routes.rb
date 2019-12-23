Rails.application.routes.draw do
  resources :teams, only: [:new, :create]
  devise_for :users

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"

  get 'month/:year/:month', to: 'log_entries#month', as: :month
  get 'jump_to_month', to: 'log_entries#jump_to_month', as: :jump_to_month
  get 'log_entries/:year/:month/:day/new', to: 'log_entries#new', as: :new_log_entry
  get 'log_entries/:year/:month/:day/edit', to: 'log_entries#edit', as: :edit_log_entry
  delete 'log_entries/:year/:month/:day/delete', to: 'log_entries#destroy', as: :delete_log_entry
  delete 'team_memberships/:team_id/delete', to: 'teams_users#destroy', as: :delete_team_membership

  resources :log_entries, only: [:new, :create, :edit, :update, :destroy]
  resources :teams_users, only: [:new, :create, :destroy], path: :team_memberships, as: :team_memberships
end
