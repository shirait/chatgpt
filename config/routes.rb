Rails.application.routes.draw do
  root "message_threads#new"
  resources :message_threads,  only: [:index, :new, :create, :show, :update, :destroy]
  resources :messages, only: [:create]
end
