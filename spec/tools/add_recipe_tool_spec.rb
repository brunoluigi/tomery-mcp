require 'rails_helper'

RSpec.describe AddRecipeTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
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
    tool.call_with_schema_validation!(token:, **recipe)

    expect(user.recipes.count).to eq(1)
  end

  it 'should not add recipe to user cookbook if title or description are missing' do
    expect do
      tool.call_with_schema_validation!(token:, **recipe.except(:title, :description))
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/title.+is missing.+description.+is missing/i)
    )

    expect(user.recipes.count).to eq(0)
  end

  it 'should not add recipe to user cookbook if ingredients are missing' do
    expect do
      tool.call_with_schema_validation!(token:, **recipe, ingredients: [])
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/size cannot be less than 1/i)
    )

    expect(user.recipes.count).to eq(0)
  end

  it 'should not add recipe to user cookbook if ingredients are missing' do
    expect do
      tool.call_with_schema_validation!(token:, **recipe, instructions: [])
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/size cannot be less than 1/i)
    )

    expect(user.recipes.count).to eq(0)
  end
end
