Rails.application.routes.draw do
  devise_for :users

  # 役割に応じてリダイレクト先を振り分ける。
  root "application#root_redirect"

  resources :chats, only: [ :new, :create, :show, :edit, :update, :destroy ] do
    member do
      post :add_message
    end
  end

  # gpt_modelsのCRUD機能は後回しとする。（当面はrails consoleから直接操作する。）
  # resources :gpt_models
end
