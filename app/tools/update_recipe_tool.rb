# frozen_string_literal: true

class UpdateRecipeTool < ApplicationTool
  description "Update recipe"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:id).filled(:string).description("Recipe ID")
    required(:title).filled(:string).description("Recipe Title")
    required(:description).filled(:string).description("Recipe description")
    required(:ingredients).value(:array, min_size?: 1).description("Recipe ingredients: [{ name: string, quantity: string }]").each do
      hash do
        required(:name).filled(:string)
        required(:quantity).filled(:string)
      end
    end
    required(:instructions).value(:array, min_size?: 1).description("Recipe instructions").each(:str?)
  end

  def call(token:, id:, title:, description:, ingredients:, instructions:)
    user = find_user_by_token(token)

    UpdateRecipeService.call!(user:, id:, title:, description:, ingredients:, instructions:)

    "OK"
  end
end
