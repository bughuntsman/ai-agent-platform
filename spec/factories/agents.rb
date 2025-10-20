FactoryBot.define do
  factory :agent do
    name { Faker::App.name }
    description { Faker::Lorem.paragraph }
    llm_provider { 'openai' }
    llm_model { 'gpt-3.5-turbo' }
    system_prompt { 'You are a helpful assistant.' }
    temperature { 0.7 }
    max_tokens { 1000 }
    configuration { {} }
    active { true }

    trait :openai do
      llm_provider { 'openai' }
      llm_model { 'gpt-4-turbo' }
    end

    trait :anthropic do
      llm_provider { 'anthropic' }
      llm_model { 'claude-3-sonnet-20240229' }
    end
  end
end
