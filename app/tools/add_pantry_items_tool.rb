# frozen_string_literal: true

class AddPantryItemsTool < ApplicationTool
  description "Add pantry items to user's inventory"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:pantry_items).array(min_size?: 1).description("Pantry items: [{ name: string, quantity: string }]").each do
      hash do
        required(:name).filled(:string).description("Pantry item description")
        required(:quantity).filled(:string).description("Pantry item quantity")
      end
    end
  end

  def call(token:, pantry_items:)
    user = find_user_by_token(token)

    AddPantryItemsService.call!(user:, pantry_items:)

    "OK"
  end
end
