# frozen_string_literal: true

class RemovePantryItemTool < ApplicationTool
  description "Remove pantry item from user's inventory"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:id).filled(:string).description("Pantry item's ID")
  end

  def call(token:, id:)
    user = find_user_by_token(token)

    user.pantry_items.where(id:).destroy_all

    "Pantry item removed successfully"
  end
end
