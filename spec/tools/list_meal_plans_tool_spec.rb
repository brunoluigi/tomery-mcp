require 'rails_helper'

RSpec.describe ListMealPlansTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }

  before {
    recipe = FactoryBot.create(:recipe, user:)
    FactoryBot.create(:meal_plan, user:, recipe:, date: 3.days.ago, meal: "breakfast")
    FactoryBot.create(:meal_plan, user:, recipe:, date: Date.today, meal: "breakfast")
    FactoryBot.create(:meal_plan, user:, recipe:, date: Date.tomorrow, meal: "lunch")
    FactoryBot.create(:meal_plan, user:, recipe:, date: 1.month.from_now, meal: "lunch")
    FactoryBot.create(:meal_plan, date: Date.today, meal: "lunch")  # from another user
  }

  it 'should list meal plans for user' do
    meal_plans, _ = tool.call_with_schema_validation!(token:, start_date: Date.today, end_date: Date.tomorrow)

    expect(JSON.parse(meal_plans).count).to eq(2)
  end

  it 'should not list meal plans for user if start_date is missing' do
    expect do
      tool.call_with_schema_validation!(token:, end_date: Date.tomorrow)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/start_date.+is missing/i)
    )
  end

  it 'should not list meal plans for user if end_date is missing' do
    expect do
      tool.call_with_schema_validation!(token:, start_date: Date.today)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/end_date.+is missing/i)
    )
  end
end
