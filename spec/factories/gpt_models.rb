FactoryBot.define do
  factory :gpt_model do
    name { "GPT-4" }
    description { "OpenAI GPT-4 model" }
    active { false }
    association :user, factory: :user, strategy: :build

    trait :active do
      active { true }
    end
  end
end

