# frozen_string_literal: true

class ListPantryItemsTool < ApplicationTool
  description "List user pantry items available for cooking"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
  end

  def call(token:)
    user = find_user_by_token(token)

    JSON.generate(user.pantry_items.as_json(only: [ :id, :name, :quantity ]))
  end
end
