# frozen_string_literal: true

class ShowRecipeTool < ApplicationTool
  description "Show recipe details"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:id).filled(:string).description("Recipe's ID")
  end

  def call(token:, id:)
    user = find_user_by_token(token)

    JSON.generate(user.recipes.find_by(id:).as_json(only: [ :id, :title, :description, :ingredients, :instructions ]))
  end
end
