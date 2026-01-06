puts "ユーザーデータを作成中..."

admin = User.new(
  name: 'admin',
  email: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: :admin,
  active: true,
  creator_id: 1,  # create時は仮の値を指定
  updater_id: 1
)
admin.save(validate: false)
admin.update(creator_id: admin.id, updater_id: admin.id)

User.create!(
  name: 'normal',
  email: 'normal@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: :normal,
  active: true,
  creator_id: admin.id,
  updater_id: admin.id
)

User.create!(
  name: 'normal2',
  email: 'normal2@example.com',
  password: 'password',
  password_confirmation: 'password',
  role: :normal,
  active: true,
  creator_id: admin.id,
  updater_id: admin.id
)
