# frozen_string_literal: true

class RemoveMealPlansTool < ApplicationTool
  description "Remove meal plans from user's calendar"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:ids).array(:string, min_size?: 1).description("Meal plan ids")
  end

  def call(token:, ids:)
    user = find_user_by_token(token)

    RemoveMealPlansService.call(user:, ids:)

    "Meal plan removed successfully"
  end
end
