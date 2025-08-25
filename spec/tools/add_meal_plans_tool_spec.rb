require 'rails_helper'

RSpec.describe AddMealPlansTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }

  it 'should add meal plans to user calendar' do
    meal_plans = [
      { recipe_id: FactoryBot.create(:recipe).id, date: Date.today, meal: "breakfast" },
      { recipe_id: FactoryBot.create(:recipe).id, date: Date.tomorrow, meal: "lunch" }
    ]

    tool.call_with_schema_validation!(token:, meal_plans:)

    expect(user.meal_plans.count).to eq(2)
  end

  it 'should not add meal plans to user calendar if date is missing' do
    meal_plans = [
      { recipe_id: FactoryBot.create(:recipe).id, meal: "breakfast" }
    ]

    expect do
      tool.call_with_schema_validation!(token:, meal_plans:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/date.+is missing/i)
    )

    expect(user.meal_plans.count).to eq(0)
  end

  it 'should not add meal plans to user calendar if meal is not breakfast, lunch, dinner or snack' do
    meal_plans = [
      { recipe_id: FactoryBot.create(:recipe).id, date: Date.today, meal: "chilling" }
    ]

    expect do
      tool.call_with_schema_validation!(token:, meal_plans:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/must be one of: breakfast, lunch, dinner, snack/i)
    )

    expect(user.meal_plans.count).to eq(0)
  end

  it 'should validate meal plans size' do
    meal_plans = []

    expect do
      tool.call_with_schema_validation!(token:, meal_plans:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/size cannot be less than 1"/i)
    )

    expect(user.meal_plans.count).to eq(0)
  end
end
