require 'rails_helper'

RSpec.describe AddMealPlansTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }

  it 'should add meal plans to user calendar' do
    meal_plans = [
      { recipe_id: FactoryBot.create(:recipe).id, date: Date.today.to_s, meal: "breakfast" },
      { recipe_id: FactoryBot.create(:recipe).id, date: Date.tomorrow.to_s, meal: "lunch" }
    ]

    call_tool_with_schema_validation!(tool:, server_context:, token:, meal_plans:)

    expect(user.meal_plans.count).to eq(2)
  end

  it 'should not add meal plans to user calendar if date is missing' do
    meal_plans = [
      { recipe_id: FactoryBot.create(:recipe).id, meal: "breakfast" }
    ]

    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, meal_plans:)
    end.to(
      raise_error.with_message(/date.+/i)
    )

    expect(user.meal_plans.count).to eq(0)
  end

  it 'should not add meal plans to user calendar if meal is not breakfast, lunch, dinner or snack' do
    meal_plans = [
      { recipe_id: FactoryBot.create(:recipe).id, date: Date.today, meal: "chilling" }
    ]

    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, meal_plans:)
    end.to(
      raise_error.with_message(/following values: breakfast, lunch, dinner, snack/i)
    )

    expect(user.meal_plans.count).to eq(0)
  end

  it 'should validate meal plans size' do
    meal_plans = []

    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, meal_plans:)
    end.to(
      raise_error.with_message(/minimum number of items 1/i)
    )

    expect(user.meal_plans.count).to eq(0)
  end
end
