FactoryBot.define do
  factory :patient do
    name { Faker::Name.name }
    date_of_birth { Faker::Date.birthday(min_age: 1, max_age: 90) }
    phone { Faker::PhoneNumber.cell_phone }
    sequence(:email) { |n| "patient#{n}@example.com" }
  end
end
