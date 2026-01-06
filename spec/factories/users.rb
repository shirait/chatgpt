FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "user#{SecureRandom.hex(4)}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    role { :normal }
    active { true }

    # ユーザーbuild時にcreator_userとupdater_userを指定できるようにする。これらは一時属性であり、creator_idやupdater_idとは異なる。
    transient do
      creator_user { nil }
      updater_user { nil }
    end

    # build時、 evaluator.creator_userやevaluator.updater_userが存在する場合はそれらをcreator_idとupdater_idに設定する。
    after(:build) do |user, evaluator|
      if evaluator.creator_user
        user.creator_id = evaluator.creator_user.id
      elsif evaluator.updater_user
        user.creator_id = evaluator.updater_user.id
      elsif User.where(role: :admin).exists?
        existing_user = User.where(role: :admin).first
        user.creator_id = existing_user.id
      else
        # 管理者ユーザーが存在しない場合は、いったん仮の値を設定。
        user.creator_id = 1
      end

      if evaluator.updater_user
        user.updater_id = evaluator.updater_user.id
      elsif evaluator.creator_user
        user.updater_id = evaluator.creator_user.id
      elsif User.where(role: :admin).exists?
        existing_user = User.where(role: :admin).first
        user.updater_id = existing_user.id
      else
        # 管理者ユーザーが存在しない場合は、いったん仮の値を設定。
        user.updater_id = 1
      end
    end

=begin
    after(:create) do |user|
      # 最初のユーザーの場合、自分自身をcreator/updaterとして設定
      if user.creator_id == 1 && !User.exists?(id: 1)
        user.update(creator_id: user.id, updater_id: user.id)
      elsif !User.exists?(id: user.creator_id)
        # creator_idが存在しない場合は、自分自身を設定
        user.update(creator_id: user.id, updater_id: user.id)
      end
    end
=end

    # build時に :admin を指定すると管理者ユーザーとして作成される。
    trait :admin do
      role { :admin }
    end

    # build時に :self_referential を指定すると、creator_idとupdater_idを自分自身に設定する。
    # （最初のadminユーザー作成時に指定すること）
    trait :self_referential do
      after(:build) do |user|
        user.creator_id = 1 # 一旦仮の値を設定
        user.updater_id = 1 # 一旦仮の値を設定
      end
      to_create do |user|
        user.save(validate: false)  # バリデーションをスキップして保存
        user.update(creator_id: user.id, updater_id: user.id)  # creator_idとupdater_idを自分自身に更新
      end
    end
  end
end
