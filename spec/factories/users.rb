FactoryBot.define do
  factory :user do
    email { "user#{SecureRandom.hex(4)}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    role { :normal }

    trait :admin do
      role { :admin }
    end
  end
end

