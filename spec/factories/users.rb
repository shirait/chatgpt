FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { "user#{SecureRandom.hex(4)}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    role { :normal }
    active { true }

    # デフォルトでは、既存のユーザーをcreator/updaterとして使用
    # 最初のユーザーを作成する場合は、:self_referentialトレイトを使用
    transient do
      creator_user { nil }
      updater_user { nil }
    end

    after(:build) do |user, evaluator|
      if evaluator.creator_user
        user.creator_id = evaluator.creator_user.id
      elsif evaluator.updater_user
        user.creator_id = evaluator.updater_user.id
      elsif User.exists?
        existing_user = User.first
        user.creator_id = existing_user.id
      else
        # 最初のユーザーの場合は、後で自分自身を設定するため一時的な値を設定
        user.creator_id = 1
      end

      if evaluator.updater_user
        user.updater_id = evaluator.updater_user.id
      elsif evaluator.creator_user
        user.updater_id = evaluator.creator_user.id
      elsif User.exists?
        existing_user = User.first
        user.updater_id = existing_user.id
      else
        # 最初のユーザーの場合は、後で自分自身を設定するため一時的な値を設定
        user.updater_id = 1
      end
    end

    after(:create) do |user|
      # 最初のユーザーの場合、自分自身をcreator/updaterとして設定
      if user.creator_id == 1 && !User.exists?(id: 1)
        user.update(creator_id: user.id, updater_id: user.id)
      elsif !User.exists?(id: user.creator_id)
        # creator_idが存在しない場合は、自分自身を設定
        user.update(creator_id: user.id, updater_id: user.id)
      end
    end

    trait :admin do
      role { :admin }
    end

    # 自分自身をcreator/updaterとして設定するtrait
    trait :self_referential do
      after(:build) do |user|
        user.creator_id = 1
        user.updater_id = 1
      end
      to_create do |user|
        # バリデーションをスキップして保存し、その後自分自身をcreator/updaterとして設定
        user.save(validate: false)
        user.update(creator_id: user.id, updater_id: user.id)
      end
    end
  end
end
