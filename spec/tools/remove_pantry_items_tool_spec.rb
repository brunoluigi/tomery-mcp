require 'rails_helper'

RSpec.describe RemovePantryItemsTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:pantry_item_1) { FactoryBot.create(:pantry_item, user:) }
  let!(:pantry_item_2) { FactoryBot.create(:pantry_item, user:) }
  let!(:pantry_item_3) { FactoryBot.create(:pantry_item, user:) }
  let!(:pantry_item_4) { FactoryBot.create(:pantry_item) }

  it 'should remove pantry items from user inventory' do
    tool.call_with_schema_validation!(token:, ids: [ pantry_item_1.id, pantry_item_2.id ])

    expect(user.pantry_items.count).to eq(1)
  end
  it "should remove pantry items from other user's inventory" do
    tool.call_with_schema_validation!(token:, ids: [ pantry_item_4.id ])

    expect(pantry_item_4.reload).to be_persisted
  end

  it 'should not remove pantry items from user inventory if ids are missing' do
    expect do
      tool.call_with_schema_validation!(token:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/ids.+is missing/i)
    )
  end
end
