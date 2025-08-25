require 'rails_helper'

RSpec.describe UpdateRecipeTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:recipe) { FactoryBot.create(:recipe, user:) }

  it 'should update recipe' do
    result, _ = tool.call_with_schema_validation!(token:, id: recipe.id, title: "New Recipe Title", description: "New Recipe Description", ingredients: recipe.ingredients, instructions: recipe.instructions)

    expect(result).to eq("OK")

    expect(recipe.reload.title).to eq("New Recipe Title")
  end

  it 'should not update recipe if id is missing' do
    expect do
      tool.call_with_schema_validation!(token:, title: "New Recipe", description: "New Recipe Description", ingredients: [ { name: "New Ingredient", quantity: "1 kg" } ], instructions: [ "New Instruction" ])
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/id.+is missing/i)
    )
  end

  it 'should not update recipe if title is missing' do
    expect do
      tool.call_with_schema_validation!(token:, id: recipe.id, description: recipe.description, ingredients: recipe.ingredients, instructions: recipe.instructions)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/title.+is missing/i)
    )
  end

  it 'should not update recipe if ingredients are missing' do
    expect do
      tool.call_with_schema_validation!(token:, id: recipe.id, title: recipe.title, description: recipe.description, instructions: recipe.instructions)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/ingredients.+is missing/i)
    )
  end

  it 'should not update recipe if ingredient quantity is missing' do
    expect do
      tool.call_with_schema_validation!(token:, id: recipe.id, title: recipe.title, description: recipe.description, ingredients: [ { name: "New Ingredient" } ], instructions: recipe.instructions)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/ingredients.+quantity.+is missing/i)
    )
  end

  it 'should not update recipe if ingredients name is missing' do
    expect do
      tool.call_with_schema_validation!(token:, id: recipe.id, title: recipe.title, description: recipe.description, ingredients: [ { quantity: "1 L" } ], instructions: recipe.instructions)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/ingredients.+name.+is missing/i)
    )
  end

  it 'should not update recipe if instructions are missing' do
    expect do
      tool.call_with_schema_validation!(token:, id: recipe.id, title: recipe.title, description: recipe.description, ingredients: recipe.ingredients)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/instructions.+is missing/i)
    )
  end
end
