puts "ユーザーデータを作成中..."

User.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
User.create!(email: 'normal@example.com', password: 'password', password_confirmation: 'password')
