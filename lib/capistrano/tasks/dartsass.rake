# dartsass-rails で application.scss をビルドするタスク
# deploy:assets:precompile の前に実行され、application.css を生成する
namespace :deploy do
  namespace :assets do
    desc "Build Dart Sass (application.scss -> application.css)"
    task :dartsass_build do
      on release_roles(fetch(:assets_roles)) do
        within release_path do
          with rails_env: fetch(:rails_env), rails_groups: fetch(:rails_assets_groups) do
            execute :rake, "dartsass:build"
          end
        end
      end
    end
  end
end

before "deploy:assets:precompile", "deploy:assets:dartsass_build"
