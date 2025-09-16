require 'rails_helper'

RSpec.describe AddPantryItemsTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }

  it 'should add pantry items to user inventory' do
    pantry_items = [
      { name: "Pasta", quantity: "1 kg" },
      { name: "Tomato", quantity: "1 kg" }
    ]

    call_tool_with_schema_validation!(tool:, server_context:, token:, pantry_items:)

    expect(user.pantry_items.count).to eq(2)
  end

  it 'should not add pantry items to user inventory if name is missing' do
    pantry_items = [
      { quantity: "1 kg" }
    ]

    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, pantry_items:)
    end.to(
      raise_error.with_message(/did not contain.+name/i)
    )

    expect(user.pantry_items.count).to eq(0)
  end

  it 'should not add pantry items to user inventory if quantity is missing' do
    pantry_items = [
      { name: "Pasta" }
    ]

    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, pantry_items:)
    end.to(
      raise_error.with_message(/did not contain.+quantity/i)
    )

    expect(user.pantry_items.count).to eq(0)
  end
end
