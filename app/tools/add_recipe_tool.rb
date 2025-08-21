# frozen_string_literal: true

class AddRecipeTool < ApplicationTool
  description "Add recipe to users cookbook"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:description).filled(:string).description("Recipe description")
    required(:ingredients).array(:hash, min_size?: 1).description("Recipe ingredients") do
      required(:name).filled(:string)
      required(:quantity).filled(:string)
    end
    required(:instructions).array(:string, min_size?: 1).description("Recipe instructions")
  end

  def call(token:, description:, ingredients:, instructions:)
    user = User.find_by_mcp_token(token)

    raise "Invalid token" unless user

    user.recipes.create!(description:, ingredients:, instructions:)

    "Recipe created successfully"
  end
end
