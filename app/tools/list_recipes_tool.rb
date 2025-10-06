# frozen_string_literal: true

class ListRecipesTool < ApplicationTool
  description "List user recipes"

  input_schema(
    properties: {},
    required: []
  )

  def self.call(server_context:)
    user = server_context[:current_user]

    MCP::Tool::Response.new([ {
      type: "text",
      text: JSON.generate(user.recipes.as_json(only: [ :id, :title, :description ]))
    } ])
  end
end
