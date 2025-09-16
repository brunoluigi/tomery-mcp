require 'rails_helper'

RSpec.describe ShowRecipeTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:recipe) { FactoryBot.create(:recipe, user:) }

  it 'should show recipe details' do
    response = call_tool_with_schema_validation!(tool:, server_context:, token:, id: recipe.id)

    expect(JSON.parse(response.content.first[:text])).to eq(
      recipe.as_json(only: [ :id, :title, :description, :ingredients, :instructions ])
    )
  end

  it 'should not show recipe details if id is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:)
    end.to(
      raise_error
      .with_message(/did not contain.+id/i)
    )
  end
end
