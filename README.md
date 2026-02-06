## ChatGPT Web版クローンアプリ

このリポジトリは、Rails で実装された ChatGPT 風のチャットアプリケーションです。  
OpenAI API を利用して、ブラウザ上から ChatGPT のように対話できます。

---

## 動作環境

- **Ruby**: 3.4.8
- **Rails**: 8.1.2
- **DB**: MariaDB

※ 詳細なバージョンは `Gemfile` / `Gemfile.lock` を参照してください。

---

## セットアップ手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/shirait/chatgpt.git
cd chatgpt
```

### 2. 依存関係のインストール

```bash
bundle install
```

### 3. 設定ファイルのコピー・編集

`config` ディレクトリ配下にある `*.sample` を元に、本番用の設定ファイルを作成します。

少なくとも次のファイルをコピー・編集してください。

- `config/database.yml.sample` → `config/database.yml`
- `config/config.yml.sample` → `config/config.yml`
- `config/email.yml.sample` → `config/email.yml`

各ファイル内で、ローカル環境に合わせて以下を設定します。

- `database.yml`: データベース名、ユーザー名、パスワード など
- `config.yml`:
  - `openai_key`: OpenAI API キー
  - `use_openai_stub`: スタブ利用有無
  - `exception_notification_enabled`: ExceptionNotification の有効無効
  - ` use_http_call`: OpenAI APIとの通信をhttpで行う。（falseにした場合、websocketを用いてリアルタイムで回答を表示します。websocketの利用にはredisのインストールが必要になります。）
- `email.yml`: 例外通知メールのfrom, to。（開発環境ではデフォルトで送信しない設定になっているので、内容を編集する必要はありません。）

---

## データベースの作成・初期化

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

---

## CSSファイルのコンパイル

```bash
bin/rails dartsass:build
```

---

## 開発サーバの起動

```bash
bin/rails server
```

ブラウザで `http://localhost:3000` にアクセスするとアプリが表示されます。

以下でログインすることでChatGPTとの対話が可能です。  
email: normal@example.com  
password: password  
※スタブを利用しない設定でエラーになる場合、 config/config.yml にOpenAI APIのキーが正しくセットされているかをご確認ください。  

利用するGPTモデルを変更したり、ユーザーのCRUDを行う場合は以下でログインしてください。  
email: admin@example.com  
password: password  

---

## テストの実行

RSpec を使用しています。

```bash
bundle exec rspec
```

---

## 例外通知 (ExceptionNotification)

例外発生時にメール通知を送るために `exception_notification` を利用しています。

- メール送信先等の設定: `config/email.yml`
- 有効／無効の切り替え: `config/config.yml` の `exception_notification_enabled`

通知は同じ例外をグルーピングし、**1, 2, 4, 8, 16... 回目** の発生時のみ送信されるようになっています。

---
