# frozen_string_literal: true

class UpdateRecipeTool < ApplicationTool
  description "Update recipe"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:id).filled(:string).description("Recipe ID")
    required(:title).filled(:string).description("Recipe Title")
    required(:description).filled(:string).description("Recipe description")
    required(:ingredients).array(:hash, min_size?: 1).description("Recipe ingredients") do
      required(:name).filled(:string)
      required(:quantity).filled(:string)
    end
    required(:instructions).array(:string, min_size?: 1).description("Recipe instructions")
  end

  def call(token:, id:, title:, description:, ingredients:, instructions:)
    user = find_user_by_token(token)

    user.recipes.find_by(id:).update!(title:, description:, ingredients:, instructions:)

    "OK"
  end
end
