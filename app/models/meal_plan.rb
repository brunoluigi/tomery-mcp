class MealPlan < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  enum :meal,  { breakfast: "breakfast", lunch: "lunch", dinner: "dinner", snack: "snack" }, validate: true
end
