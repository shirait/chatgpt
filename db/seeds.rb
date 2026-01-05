seed_files = [
  "users.rb",
  "gpt_models.rb"
]

seed_files.each do |file|
  puts "Loading #{file}..."
  load(Rails.root.join('db', 'seeds', Rails.env, file))
end
