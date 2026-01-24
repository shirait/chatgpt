# Pin npm packages by running ./bin/importmap

# 全ページで読み込むものは application.js で読み込む。
# 個別ページで読み込みたいものは、こちらでJSの名前と実体の対応を定義する。
# ↓呼び出し例
# import "navbar_burger"
# import ChatChannel from "channels/chat_channel"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "navbar_burger", to: "navbar_burger.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "channels/chat_channel", to: "channels/chat_channel.js"
pin "marked", to: "marked.esm.js"
