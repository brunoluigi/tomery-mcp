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

    pantry_item = user.pantry_items.find_or_create_by!(name:)
    pantry_item.update!(quantity:)

    "Pantry item #{pantry_item.new_record? ? "created" : "updated"} successfully"
  end
end
