FactoryBot.define do
  factory :tenant do
    name { Faker::Company.name }
    subdomain { Faker::Internet.slug(words: nil, glue: '-') }
    settings { {} }
    active { true }
  end
end
