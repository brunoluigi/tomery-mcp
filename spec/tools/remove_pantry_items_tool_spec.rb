require 'rails_helper'

RSpec.describe RemovePantryItemsTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:pantry_item_1) { FactoryBot.create(:pantry_item, user:) }
  let!(:pantry_item_2) { FactoryBot.create(:pantry_item, user:) }
  let!(:pantry_item_3) { FactoryBot.create(:pantry_item, user:) }
  let!(:pantry_item_4) { FactoryBot.create(:pantry_item) }

  it 'should remove pantry items from user inventory' do
    call_tool_with_schema_validation!(tool:, server_context:, token:, ids: [ pantry_item_1.id, pantry_item_2.id ])

    expect(user.pantry_items.count).to eq(1)
  end
  it "should remove pantry items from other user's inventory" do
    call_tool_with_schema_validation!(tool:, server_context:, token:, ids: [ pantry_item_4.id ])

    expect(pantry_item_4.reload).to be_persisted
  end

  it 'should not remove pantry items from user inventory if ids are missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:)
    end.to(
      raise_error
      .with_message(/did not contain.+ids/i)
    )
  end
end
