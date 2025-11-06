require 'rails_helper'

RSpec.describe ListRecipesTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }

  before {
    FactoryBot.create(:recipe, user:)
    FactoryBot.create(:recipe, user:)
    FactoryBot.create(:recipe) # from another user
  }

  it 'should list recipes for user' do
    response = call_tool_with_schema_validation!(tool:, server_context:)

    expect(JSON.parse(response.content.first[:text]).count).to eq(2)
  end
end
