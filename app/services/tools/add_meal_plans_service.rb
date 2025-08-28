# frozen_string_literal: true

class Tools::AddMealPlansService
  def self.call!(user:, meal_plans:)
    user.meal_plans.create!(meal_plans)
  end
end
