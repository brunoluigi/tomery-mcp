# frozen_string_literal: true

class UpdatePantryItemQuantityTool < ApplicationTool
  description "Update pantry item quantity in user's inventory"

  arguments do
    required(:token).filled(:string).description("Token of the user's session")
    required(:name).filled(:string).description("Pantry item name")
    required(:quantity).filled(:string).description("Pantry item quantity")
  end

  def call(token:, name:, quantity:)
    user = find_user_by_token(token)

    UpdatePantryItemQuantityService.call!(user:, name:, quantity:)

    "OK"
  end
end
