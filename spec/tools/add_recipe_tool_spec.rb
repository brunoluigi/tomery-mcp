require 'rails_helper'

RSpec.describe AddRecipeTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }
  let(:recipe) do
    {
      title: "Pasta",
      description: "Pasta recipe",
      ingredients: [
        { name: "Pasta", quantity: "1 kg" },
        { name: "Tomato", quantity: "1 kg" }
      ],
      instructions: [
        "Cook pasta",
        "Cook tomato"
      ]
    }
  end

  it 'should add recipe to user cookbook' do
    call_tool_with_schema_validation!(tool:, server_context:, token:, **recipe)

    expect(user.recipes.count).to eq(1)
  end

  it 'should not add recipe to user cookbook if title or description are missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, **recipe.except(:title, :description))
    end.to(
      raise_error
      .with_message(/did not contain.+title.+description/i)
    )

    expect(user.recipes.count).to eq(0)
  end

  it 'should not add recipe to user cookbook if ingredients are missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, **recipe, ingredients: [ { ingredient: "pasta", amount: "1 packet" } ])
    end.to(
      raise_error
      .with_message(/did not contain.+name.+quantity/i)
    )

    expect(user.recipes.count).to eq(0)
  end

  it 'should not add recipe to user cookbook if ingredients are in the wrong format' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, **recipe, ingredients: [])
    end.to(
      raise_error
      .with_message(/minimum number of items 1/i)
    )

    expect(user.recipes.count).to eq(0)
  end

  it 'should not add recipe to user cookbook if instructions are missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, **recipe, instructions: [])
    end.to(
      raise_error
      .with_message(/minimum number of items 1/i)
    )

    expect(user.recipes.count).to eq(0)
  end
end
