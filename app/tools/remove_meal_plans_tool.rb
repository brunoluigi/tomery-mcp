# frozen_string_literal: true

class RemoveMealPlansTool < ApplicationTool
  description "Remove meal plans from user's calendar"

  input_schema(
    properties: {
      token: { type: "string", description: "Token of the user's session", minLength: 1 },
      ids: {
        type: "array",
        minItems: 1,
        description: "Meal plan ids",
        items: { type: "string", minLength: 1 }
      }
    },
    required: [ "token", "ids" ]
  )

  def self.call(token:, ids:, server_context:)
    user = server_context[:current_user]

    Tools::RemoveMealPlansService.call(user:, ids:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "Meal plan removed successfully"
    } ])
  end
end
