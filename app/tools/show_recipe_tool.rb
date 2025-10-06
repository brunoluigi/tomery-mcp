# frozen_string_literal: true

class ShowRecipeTool < ApplicationTool
  description "Show recipe details"

  input_schema(
    properties: {
      id: { type: "string", description: "Recipe's ID", minLength: 1 }
    },
    required: [ "id" ]
  )

  def self.call(id:, server_context:)
    user = server_context[:current_user]

    MCP::Tool::Response.new([ {
      type: "text",
      text: JSON.generate(user.recipes.find_by(id:).as_json(only: [ :id, :title, :description, :ingredients, :instructions ]))
    } ])
  end
end
