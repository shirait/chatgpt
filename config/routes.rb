Rails.application.routes.draw do
  # ActionCableのマウント
  mount ActionCable.server => "/cable"

  devise_for(:users, controllers: {
    # カスタムコントローラー利用設定
    confirmations: "users/confirmations",
    # omniauth_callbacks: 'users/omniauth_callbacks', # user.rb で :omniauthableを有効にしたら指定する。
    passwords: "users/passwords",
    registrations: "users/registrations",
    unlocks: "users/unlocks",
    sessions: "users/sessions"
  })

  root("application#root_redirect")

  resources(:chats, only: [ :new, :create, :show, :edit, :update, :destroy ]) do
    member do
      post(:add_message)
      delete(:delete_messages)
      get(:edit_tag_message_thread)
      post(:update_tag_message_thread)
      post(:hide)
      post(:open)
    end
    collection do
      get(:search)
    end
  end

  resources(:tags)

  namespace(:admin) do
    resources(:users)

    resources(:gpt_models)
  end
end
