# デプロイ先サーバーの設定（ホスト名またはIPアドレスを指定）
# TODO: 実際のサーバー情報に置き換えてください
server "your-server.example.com", user: "chatgpt", roles: %w[app db web]

# TODO: 実際のポートを指定して下さい。
set :ssh_options, { port: 22 }

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}

namespace :deploy do
=begin
  desc "passenger restart"
  task :restart_app do
    on roles(:app) do
      execute("touch /home/chatgpt/production/current/tmp/restart.txt")
    end
  end
=end

  desc "setup bundle config"
  task :setup_bundle_config do
    on roles(:app) do
      within release_path do
        execute :bundle, "config set --local path vendor/bundle"
        execute :bundle, "config set --local deployment true"
        execute :bundle, 'config set --local without "development test"'
      end
    end
  end
end

# https://github.com/shirait/programs/issues/39 の対処で追加したが、いらないかもしれない。
before "bundler:install", "deploy:setup_bundle_config"

# デプロイ後にPumaを再起動
after "deploy:published", "puma:restart"

# デプロイ後、passenger再起動ファイルを配置。
# after "deploy:published", "deploy:restart_app"
