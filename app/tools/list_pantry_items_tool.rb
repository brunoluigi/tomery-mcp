# frozen_string_literal: true

class ListPantryItemsTool < ApplicationTool
  description "List user pantry items available for cooking"

  input_schema(
    properties: {},
    required: []
  )

  def self.call(server_context:)
    user = server_context[:current_user]

    MCP::Tool::Response.new([ {
      type: "text",
      text: JSON.generate(user.pantry_items.as_json(only: [ :id, :name, :quantity ]))
    } ])
  end
end
