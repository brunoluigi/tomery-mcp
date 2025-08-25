require 'rails_helper'

RSpec.describe ListPantryItemsTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }

  before {
    FactoryBot.create(:pantry_item, user:, name: "tomato", quantity: "1")
    FactoryBot.create(:pantry_item, user:, name: "potato", quantity: "2")
    FactoryBot.create(:pantry_item, name: "cheese", quantity: "2")  # from another user
  }

  it 'should list pantry items for user' do
    pantry_items, _ = tool.call_with_schema_validation!(token:)

    expect(JSON.parse(pantry_items).count).to eq(2)
  end
end
