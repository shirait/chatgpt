Rails.application.routes.draw do
  root "message_threads#new"

  resources :message_threads do
    member do
      post :add_message
    end
  end

  resources :messages, only: [:create]
end
