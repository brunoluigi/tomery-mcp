# frozen_string_literal: true

class ListRecipesTool < ApplicationTool
  description "List user recipies"

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
      text: JSON.generate(user.recipes.as_json(only: [ :id, :title, :description ]))
    } ])
  end
end
