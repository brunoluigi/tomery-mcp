# frozen_string_literal: true

class UpdateRecipeTool < ApplicationTool
  description "Update recipe"

  input_schema(
    properties: {
      id: { type: "string", description: "Recipe ID", minLength: 1 },
      title: { type: "string", description: "Recipe Title", minLength: 1 },
      description: { type: "string", description: "Recipe description", minLength: 1 },
      ingredients: {
        type: "array",
        minItems: 1,
        description: "Recipe ingredients: [{ name: string, quantity: string }]",
        items: {
          type: "object",
          properties: {
            name: { type: "string", minLength: 1 },
            quantity: { type: "string", minLength: 1 }
          },
          required: [ "name", "quantity" ]
        }
      },
      instructions: {
        type: "array",
        minItems: 1,
        description: "Recipe instructions: [string]",
        items: { type: "string", minLength: 1 }
      }
    },
    required: [ "id", "title", "description", "ingredients", "instructions" ]
  )

  def self.call(id:, title:, description:, ingredients:, instructions:, server_context:)
    user = server_context[:current_user]

    Tools::UpdateRecipeService.call!(user:, id:, title:, description:, ingredients:, instructions:)

    MCP::Tool::Response.new([ {
      type: "text",
      text: "OK"
    } ])
  end
end
