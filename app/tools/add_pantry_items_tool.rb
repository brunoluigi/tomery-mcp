# frozen_string_literal: true

class AddPantryItemsTool < ApplicationTool
  description "Add pantry items to user's inventory"

  input_schema(
    properties: {
      token: { type: "string", description: "Token of the user's session", minLength: 1 },
      pantry_items: {
        type: "array",
        minItems: 1,
        description: "Pantry items: [{ name: string, quantity: string }]",
        items: {
          type: "object",
          properties: {
            name: { type: "string", description: "Pantry item description", minLength: 1 },
            quantity: { type: "string", description: "Pantry item quantity", minLength: 1 }
          },
          required: [ "name", "quantity" ]
        }
      }
    },
    required: [ "token", "pantry_items" ]
  )

  def self.call(token:, pantry_items:, server_context:)
    user = server_context[:current_user]

    Tools::AddPantryItemsService.call!(user:, pantry_items:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "OK"
    } ])
  end
end
