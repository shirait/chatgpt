Rails.application.routes.draw do
  root "chats#new"

  resources :chats, only: [ :new, :create, :show, :edit, :update, :destroy ] do
    member do
      post :add_message
    end
  end

  # gpt_modelsのCRUD機能は後回しとする。（当面はrails consoleから直接操作する。）
  # resources :gpt_models
end
