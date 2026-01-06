puts "ユーザーデータを作成中..."

User.create!(name: 'admin', email: 'admin@example.com',   password: 'password', password_confirmation: 'password', role: :admin, active: true)
User.create!(name: 'normal', email: 'normal@example.com',  password: 'password', password_confirmation: 'password', role: :normal, active: true)
User.create!(name: 'normal2', email: 'normal2@example.com', password: 'password', password_confirmation: 'password', role: :normal, active: true)
