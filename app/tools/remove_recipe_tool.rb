# frozen_string_literal: true

class RemoveRecipeTool < ApplicationTool
  description "Remove recipe from user's cookbook"

  input_schema(
    properties: {
      token: { type: "string", description: "Token of the user's session", minLength: 1 },
      id: { type: "string", description: "Recipe's ID", minLength: 1 }
    },
    required: [ "token", "id" ]
  )

  def self.call(token:, id:, server_context:)
    user = server_context[:current_user]

    Tools::RemoveRecipeService.call(user:, id:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "OK"
    } ])
  end
end
