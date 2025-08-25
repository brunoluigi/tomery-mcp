# frozen_string_literal: true

class AddMealPlansTool < ApplicationTool
  description "Add meal plans to user's calendar"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:meal_plans).value(:array, min_size?: 1).description("Meal plans array of objects: {recipe_id: string, date: date, meal: [breakfast|lunch|dinner|snack]}").each do
      hash do
        required(:recipe_id).filled(:string).description("Recipe ID")
        required(:date).filled(:date).description("Date of the meal")
        required(:meal).filled(:string).value(included_in?: [ "breakfast", "lunch", "dinner", "snack" ]).description("Meal of the day: breakfast, lunch, dinner, snack")
      end
    end
  end

  def call(token:, meal_plans:)
    user = find_user_by_token(token)

    AddMealPlansService.call!(user:, meal_plans:)

    "OK"
  end
end
