require 'rails_helper'

RSpec.describe UpdatePantryItemQuantityTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:pantry_item) { FactoryBot.create(:pantry_item, user:) }

  it 'should update pantry item quantity' do
    result, _ = tool.call_with_schema_validation!(token:, name: pantry_item.name, quantity: "2 kg")

    expect(result).to eq("OK")

    expect(pantry_item.reload.quantity).to eq("2 kg")
  end

  it 'should create a new pantry item quantity' do
    expect do
      tool.call_with_schema_validation!(token:, name: "New Pantry Item", quantity: "1 kg")
    end.to change(user.pantry_items, :count).by(1)
  end

  it 'should not update pantry item quantity if name is missing' do
    expect do
      tool.call_with_schema_validation!(token:, quantity: "2")
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/name.+is missing/i)
    )
  end

  it 'should not update pantry item quantity if quantity is missing' do
    expect do
      tool.call_with_schema_validation!(token:, name: pantry_item.name)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/quantity.+is missing/i)
    )
  end
end
