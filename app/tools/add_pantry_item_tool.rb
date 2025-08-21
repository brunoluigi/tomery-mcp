# frozen_string_literal: true

class AddPantryItemTool < ApplicationTool
  description "Add pantry item to user's inventory"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:name).filled(:string).description("Pantry item description")
    required(:quantity).filled(:string).description("Pantry item quantity")
  end

  def call(token:, name:, quantity:)
    user = find_user_by_token(token)

    user.pantry_items.create!(name:, quantity:)

    "Pantry item created successfully"
  end
end
