# Pin npm packages by running ./bin/importmap

# JSの名前と実体の対応を定義する。
# 全ページで読み込むものは application.js で読み込む。
# それ以外は <script type="module"> で, 「import」 で読み込む。（例： _websocket.js.erb ）
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "navbar_burger", to: "navbar_burger.js"
pin "@rails/actioncable", to: "actioncable.esm.js"
pin "channels/chat_channel", to: "channels/chat_channel.js"
pin "marked", to: "marked.esm.js"
