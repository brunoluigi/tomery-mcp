# frozen_string_literal: true

class RemovePantryItemsTool < ApplicationTool
  description "Remove pantry items from user's inventory"

  input_schema(
    properties: {
      token: { type: "string", description: "Token of the user's session", minLength: 1 },
      ids: {
        type: "array",
        minItems: 1,
        description: "Pantry item ids",
        items: { type: "string", minLength: 1 }
      }
    },
    required: [ "token", "ids" ]
  )

  def self.call(token:, ids:, server_context:)
    user = server_context[:current_user]

    Tools::RemovePantryItemsService.call(user:, ids:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "OK"
    } ])
  end
end
