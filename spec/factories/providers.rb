FactoryBot.define do
  factory :provider do
    association :user, factory: [ :user, :provider ]
    specialty { "General Practice" }
    bio { Faker::Lorem.paragraph }
  end
end
