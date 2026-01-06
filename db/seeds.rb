# 既存データを削除
debugger
if Rails.env.development?
  GptModel.destroy_all
  User.delete_all # destroy_allだとadminユーザーが削除されない（creator_idとupdater_idが自分自身のため）
end

seed_files = [
  "users.rb",
  "gpt_models.rb"
]

seed_files.each do |file|
  puts "Loading #{file}..."
  load(Rails.root.join('db', 'seeds', Rails.env, file))
end
