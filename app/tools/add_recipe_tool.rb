# frozen_string_literal: true

class AddRecipeTool < ApplicationTool
  description "Add recipe to users cookbook"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:title).filled(:string).description("Recipe Title")
    required(:description).filled(:string).description("Recipe description")
    required(:ingredients).value(:array, min_size?: 1).description("Recipe ingredients").each do
      hash do
        required(:name).filled(:string)
        required(:quantity).filled(:string)
      end
    end
    required(:instructions).value(:array, min_size?: 1).description("Recipe instructions").each(:str?)
  end

  def call(token:, title:, description:, ingredients:, instructions:)
    user = find_user_by_token(token)

    recipe = AddRecipeService.call!(user:, title:, description:, ingredients:, instructions:)

    "Created with ID: #{recipe.id}"
  end
end
