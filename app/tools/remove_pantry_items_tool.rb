# frozen_string_literal: true

class RemovePantryItemsTool < ApplicationTool
  description "Remove pantry items from user's inventory"

  input_schema(
    properties: {
      ids: {
        type: "array",
        minItems: 1,
        description: "Pantry item ids",
        items: { type: "string", minLength: 1 }
      }
    },
    required: [ "ids" ]
  )

  def self.call(ids:, server_context:)
    user = server_context[:current_user]

    Tools::RemovePantryItemsService.call(user:, ids:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "OK"
    } ])
  end
end
