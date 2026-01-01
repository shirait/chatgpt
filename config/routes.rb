Rails.application.routes.draw do
  devise_for :users, controllers: {
    # カスタムコントローラー利用設定
    confirmations: 'users/confirmations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    unlocks: 'users/unlocks',
    sessions: 'users/sessions',
  }

  # 役割に応じてリダイレクト先を振り分ける。
  root "application#root_redirect"

  resources :chats, only: [ :new, :create, :show, :edit, :update, :destroy ] do
    member do
      post :add_message
    end
    collection do
      get :search
    end
  end

  # gpt_modelsのCRUD機能は後回しとする。（当面はrails consoleから直接操作する。）
  # resources :gpt_models
end
