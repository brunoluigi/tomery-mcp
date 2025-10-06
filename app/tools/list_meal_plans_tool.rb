# frozen_string_literal: true

class ListMealPlansTool < ApplicationTool
  description "List user meals for a given date interval"

  input_schema(
    properties: {
      start_date: { type: "string", format: "date", description: "Start date of the interval", minLength: 1 },
      end_date: { type: "string", format: "date", description: "End date of the interval", minLength: 1 }
    },
    required: [ "start_date", "end_date" ]
  )

  def self.call(start_date:, end_date:, server_context:)
    user = server_context[:current_user]

    meal_plans = Tools::ListMealPlansService.call(user:, start_date:, end_date:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: JSON.generate(meal_plans.as_json(only: [ :id, :date, :meal ], include: { recipe: { only: [ :id, :title, :description ] } }))
    } ])
  end
end
