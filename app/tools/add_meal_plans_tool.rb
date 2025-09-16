# frozen_string_literal: true

class AddMealPlansTool < ApplicationTool
  description "Add meal plans to user's calendar"

  input_schema(
    properties: {
      token: { type: "string", description: "Token of the user's session", minLength: 1 },
      meal_plans: {
        type: "array",
        minItems: 1,
        description: "Meal plans array of objects: [{recipe_id: string, date: date, meal: [breakfast|lunch|dinner|snack]}]",
        items: {
          type: "object",
          properties: {
            recipe_id: { type: "string", description: "Recipe ID", minLength: 1 },
            date: { type: "string", format: "date", description: "Date of the meal", minLength: 1 },
            meal: { type: "string", enum: [ "breakfast", "lunch", "dinner", "snack" ], description: "Meal of the day: breakfast, lunch, dinner, snack" }
          },
          required: [ "recipe_id", "date", "meal" ]
        }
      }
    },
    required: [ "token", "meal_plans" ]
  )

  def self.call(token:, meal_plans:, server_context:)
    user = server_context[:current_user]

    Tools::AddMealPlansService.call!(user:, meal_plans:)

    MCP::Tool::Response.new([ {
          type: "text",
          text: "OK"
        } ])
  end
end
