Rails.application.routes.draw do
  root "chats#new"

  resources :chats do
    member do
      post :add_message
    end
  end
end
