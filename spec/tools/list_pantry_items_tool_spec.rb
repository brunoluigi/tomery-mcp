require 'rails_helper'

RSpec.describe ListPantryItemsTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }

  before {
    FactoryBot.create(:pantry_item, user:, name: "tomato", quantity: "1")
    FactoryBot.create(:pantry_item, user:, name: "potato", quantity: "2")
    FactoryBot.create(:pantry_item, name: "cheese", quantity: "2")  # from another user
  }

  it 'should list pantry items for user' do
    response = call_tool_with_schema_validation!(tool:, server_context:)

    expect(JSON.parse(response.content.first[:text]).count).to eq(2)
  end
end
