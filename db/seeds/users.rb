puts "ユーザーデータを作成中..."

User.create!(email: 'admin@example.com',   password: 'password', password_confirmation: 'password', role: :admin)
User.create!(email: 'normal@example.com',  password: 'password', password_confirmation: 'password', role: :normal)
User.create!(email: 'normal2@example.com', password: 'password', password_confirmation: 'password', role: :normal)
