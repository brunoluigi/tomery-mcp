# frozen_string_literal: true

class ListPantryItemsTool < ApplicationTool
  description "List user pantry items available for cooking"

  input_schema(
    properties: {
      token: { type: "string", description: "Token of the user's session", minLength: 1 }
    },
    required: [ "token" ]
  )

  def self.call(token:, server_context:)
    user = server_context[:current_user]

    MCP::Tool::Response.new([ {
      type: "text",
      text: JSON.generate(user.pantry_items.as_json(only: [ :id, :name, :quantity ]))
    } ])
  end
end
