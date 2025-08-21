# frozen_string_literal: true

class ListRecipesTool < ApplicationTool
  description "List user recipies"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
  end

  def call(token:)
    user = find_user_by_token(token)

    JSON.generate(user.recipes.as_json(only: [ :id, :title, :description ]))
  end
end
