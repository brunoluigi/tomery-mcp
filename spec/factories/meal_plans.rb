FactoryBot.define do
  factory :meal_plan do
    user
    recipe
    meal { "breakfast" }
    date { Date.today }
  end
end
