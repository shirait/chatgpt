lock "~> 3.20.0"

# github settings
set :application, "chatgpt"
set :repo_url, "git@github.com:shirait/chatgpt.git"
set :branch, "master"
set :user, "chatgpt"

# deploy settings
set :deploy_to, "/home/chatgpt/production"

# set ruby settings
set :rbenv_type, :system  # rbenvのインストール先。「/home/ユーザー名/rbenv」なら:userを、「/usr/local/rbenv」なら:systemを指定する。
set :rbenv_path, "/usr/local/rbenv" # rbenv_typeを指定しているので不要かもしれない。
set :rbenv_ruby, "3.4.8"
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails]
set :rbenv_roles, :all

# linked files and directories
# たぶん 'config/credentials.yml.enc' は不要。検証のうえ消す。
append :linked_files, "config/database.yml", "config/config.yml", "config/credentials/production.key", "config/credentials/production.yml.enc"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle", ".bundle", "public/system", "storage"

# bundle settings
set :bundle_path, -> { shared_path.join("vendor/bundle") }
set :bundle_flags, "--deployment --quiet"
