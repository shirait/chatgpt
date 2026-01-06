FactoryBot.define do
  factory :message_thread do
    title { "Test Thread" }
    association :user, factory: :user
  end
end
