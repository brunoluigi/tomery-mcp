require 'rails_helper'

RSpec.describe AddPantryItemsTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }

  it 'should add pantry items to user inventory' do
    pantry_items = [
      { name: "Pasta", quantity: "1 kg" },
      { name: "Tomato", quantity: "1 kg" }
    ]

    tool.call_with_schema_validation!(token:, pantry_items:)

    expect(user.pantry_items.count).to eq(2)
  end

  it 'should not add pantry items to user inventory if name is missing' do
    pantry_items = [
      { quantity: "1 kg" }
    ]

    expect do
      tool.call_with_schema_validation!(token:, pantry_items:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/name.+is missing/i)
    )

    expect(user.pantry_items.count).to eq(0)
  end

  it 'should not add pantry items to user inventory if quantity is missing' do
    pantry_items = [
      { name: "Pasta" }
    ]

    expect do
      tool.call_with_schema_validation!(token:, pantry_items:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/quantity.+is missing/i)
    )

    expect(user.pantry_items.count).to eq(0)
  end
end
