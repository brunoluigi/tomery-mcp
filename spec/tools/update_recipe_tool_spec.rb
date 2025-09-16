require 'rails_helper'

RSpec.describe UpdateRecipeTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:recipe) { FactoryBot.create(:recipe, user:) }

  it 'should update recipe' do
    response = call_tool_with_schema_validation!(tool:, server_context:, token:, id: recipe.id, title: "New Recipe Title", description: "New Recipe Description", ingredients: recipe.ingredients, instructions: recipe.instructions)

    expect(response.content.first[:text]).to eq("OK")

    expect(recipe.reload.title).to eq("New Recipe Title")
  end

  it 'should not update recipe if id is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, title: "New Recipe", description: "New Recipe Description", ingredients: [ { name: "New Ingredient", quantity: "1 kg" } ], instructions: [ "New Instruction" ])
    end.to(
      raise_error
      .with_message(/did not contain.+id/i)
    )
  end

  it 'should not update recipe if title is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, id: recipe.id, description: recipe.description, ingredients: recipe.ingredients, instructions: recipe.instructions)
    end.to(
      raise_error
      .with_message(/did not contain.+title/i)
    )
  end

  it 'should not update recipe if ingredients are missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, id: recipe.id, title: recipe.title, description: recipe.description, instructions: recipe.instructions)
    end.to(
      raise_error
      .with_message(/did not contain.+ingredients/i)
    )
  end

  it 'should not update recipe if ingredient quantity is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, id: recipe.id, title: recipe.title, description: recipe.description, ingredients: [ { name: "New Ingredient" } ], instructions: recipe.instructions)
    end.to(
      raise_error
      .with_message(/ingredients.+did not contain.+quantity/i)
    )
  end

  it 'should not update recipe if ingredients name is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, id: recipe.id, title: recipe.title, description: recipe.description, ingredients: [ { quantity: "1 L" } ], instructions: recipe.instructions)
    end.to(
      raise_error
      .with_message(/ingredients.+did not contain.+name/i)
    )
  end

  it 'should not update recipe if instructions are missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, id: recipe.id, title: recipe.title, description: recipe.description, ingredients: recipe.ingredients)
    end.to(
      raise_error
      .with_message(/did not contain.+instructions/i)
    )
  end
end
