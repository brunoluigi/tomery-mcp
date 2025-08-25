# frozen_string_literal: true

class RemovePantryItemsTool < ApplicationTool
  description "Remove pantry items from user's inventory"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:ids).array(:string, min_size?: 1).description("Pantry item ids")
  end

  def call(token:, ids:)
    user = find_user_by_token(token)

    RemovePantryItemsService.call(user:, ids:)

    "OK"
  end
end
