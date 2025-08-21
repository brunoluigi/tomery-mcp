# frozen_string_literal: true

class RemoveRecipeTool < ApplicationTool
  description "Remove recipe from users cookbook"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:id).filled(:string).description("Recipe's ID")
  end

  def call(token:, id:)
    user = User.find_by_mcp_token(token)

    raise "Invalid token" unless user

    user.recipes.where(id:).destroy_all

    "Recipe removed successfully"
  end
end
