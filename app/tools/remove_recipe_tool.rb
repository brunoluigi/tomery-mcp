# frozen_string_literal: true

class RemoveRecipeTool < ApplicationTool
  description "Remove recipe from user's cookbook"

  input_schema(
    properties: {
      id: { type: "string", description: "Recipe's ID", minLength: 1 }
    },
    required: [ "id" ]
  )

  def self.call(id:, server_context:)
    user = server_context[:current_user]

    Tools::RemoveRecipeService.call(user:, id:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "OK"
    } ])
  end
end
