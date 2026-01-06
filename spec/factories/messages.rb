FactoryBot.define do
  factory :message do
    content { "Test message content" }
    message_type { :user }
    association :user, factory: :user
    association :gpt_model, factory: :gpt_model
    association :message_thread, factory: :message_thread

    trait :assistant do
      message_type { :assistant }
    end
  end
end
