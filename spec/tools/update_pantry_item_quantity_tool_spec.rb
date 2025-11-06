require 'rails_helper'

RSpec.describe UpdatePantryItemQuantityTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:pantry_item) { FactoryBot.create(:pantry_item, user:) }

  it 'should update pantry item quantity' do
    response = call_tool_with_schema_validation!(tool:, server_context:, name: pantry_item.name, quantity: "2 kg")

    expect(response.content.first[:text]).to eq("OK")

    expect(pantry_item.reload.quantity).to eq("2 kg")
  end

  it 'should create a new pantry item quantity' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, name: "New Pantry Item", quantity: "1 kg")
    end.to change(user.pantry_items, :count).by(1)
  end

  it 'should not update pantry item quantity if name is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, quantity: "2")
    end.to(
      raise_error
      .with_message(/did not contain.+name/i)
    )
  end

  it 'should not update pantry item quantity if quantity is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, name: pantry_item.name)
    end.to(
      raise_error
      .with_message(/did not contain.+quantity/i)
    )
  end
end
