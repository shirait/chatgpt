Rails.application.routes.draw do
  root "chats#new"

  resources :chats, only: [:new, :create, :show, :edit, :update, :destroy] do
    member do
      post :add_message
    end
  end
end
