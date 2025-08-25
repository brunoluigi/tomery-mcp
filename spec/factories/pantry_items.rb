FactoryBot.define do
  factory :pantry_item do
    user
    name { Faker::Food.ingredient }
    quantity { Faker::Food.measurement }
  end
end
