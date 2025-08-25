FactoryBot.define do
  factory :recipe do
    user
    title { Faker::Food.dish }
    description { Faker::Food.description }
    ingredients { 4.times.map { { name: Faker::Food.ingredients, quantity: Faker::Food.measurement } } }
    instructions { 4.times.map { Faker::ChuckNorris.fact } }
  end
end
