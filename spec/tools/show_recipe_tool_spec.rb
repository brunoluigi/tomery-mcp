require 'rails_helper'

RSpec.describe ShowRecipeTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:recipe) { FactoryBot.create(:recipe, user:) }

  it 'should show recipe details' do
    result, _ = tool.call_with_schema_validation!(token:, id: recipe.id)

    expect(JSON.parse(result)).to eq(recipe.as_json(only: [ :id, :title, :description, :ingredients, :instructions ]))
  end

  it 'should not show recipe details if id is missing' do
    expect do
      tool.call_with_schema_validation!(token:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/id.+is missing/i)
    )
  end
end
