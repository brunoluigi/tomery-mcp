# frozen_string_literal: true

class RemoveMealPlansTool < ApplicationTool
  description "Remove meal plans from user's calendar"

  input_schema(
    properties: {
      ids: {
        type: "array",
        minItems: 1,
        description: "Meal plan ids",
        items: { type: "string", minLength: 1 }
      }
    },
    required: [ "ids" ]
  )

  def self.call(ids:, server_context:)
    user = server_context[:current_user]

    Tools::RemoveMealPlansService.call(user:, ids:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "Meal plan removed successfully"
    } ])
  end
end
