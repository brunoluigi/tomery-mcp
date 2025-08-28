# frozen_string_literal: true

class ListMealPlansTool < ApplicationTool
  description "List user meals for a given date interval"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:start_date).filled(:date).description("Start date of the interval")
    required(:end_date).filled(:date).description("End date of the interval")
  end

  def call(token:, start_date:, end_date:)
    user = find_user_by_token(token)

    meal_plans = Tools::ListMealPlansService.call(user:, start_date:, end_date:)

    JSON.generate(meal_plans.as_json(only: [ :id, :date, :meal ], include: { recipe: { only: [ :id, :title, :description ] } }))
  end
end
