Rails.application.routes.draw do
  resources :teams
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"

  get 'month/:year/:month', to: 'log_entries#month', as: :month
  get 'log_entries/:year/:month/:day/new', to: 'log_entries#new', as: :new_log_entry
  get 'log_entries/:year/:month/:day/edit', to: 'log_entries#edit', as: :edit_log_entry
  delete 'log_entries/:year/:month/:day/delete', to: 'log_entries#destroy', as: :delete_log_entry

  resources :log_entries
  #post 'log_entr', to: 'log_entries#create', as: :log_entry
end
