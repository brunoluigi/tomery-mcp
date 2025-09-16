# frozen_string_literal: true

class UpdatePantryItemQuantityTool < ApplicationTool
  description "Update pantry item quantity in user's inventory"

  input_schema(
    properties: {
      token: { type: "string", description: "Token of the user's session", minLength: 1 },
      name: { type: "string", description: "Pantry item name", minLength: 1 },
      quantity: { type: "string", description: "Pantry item quantity", minLength: 1 }
    },
    required: [ "token", "name", "quantity" ]
  )

  def self.call(token:, name:, quantity:, server_context:)
    user = server_context[:current_user]

    Tools::UpdatePantryItemQuantityService.call!(user:, name:, quantity:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "OK"
    } ])
  end
end
