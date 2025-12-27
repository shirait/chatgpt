Rails.application.routes.draw do
  root "threads#new"
  resources :threads,  only: [:index, :new, :create, :show, :update, :destroy]
  resources :messages, only: [:create]
end
