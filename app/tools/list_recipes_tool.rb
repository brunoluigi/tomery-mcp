# frozen_string_literal: true

class ListRecipesTool < ApplicationTool
  description "List user recipies"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
  end

  def call(token:)
    user = User.find_by_mcp_token(token)

    raise "Invalid token" unless user

    JSON.generate(user.recipes.as_json(only: [ :id, :description, :ingredients, :instructions ]))
  end
end
