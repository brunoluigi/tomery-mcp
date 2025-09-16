require 'rails_helper'

RSpec.describe ListMealPlansTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }

  before {
    recipe = FactoryBot.create(:recipe, user:)
    FactoryBot.create(:meal_plan, user:, recipe:, date: 3.days.ago.to_s, meal: "breakfast")
    FactoryBot.create(:meal_plan, user:, recipe:, date: Date.today.to_s, meal: "breakfast")
    FactoryBot.create(:meal_plan, user:, recipe:, date: Date.tomorrow.to_s, meal: "lunch")
    FactoryBot.create(:meal_plan, user:, recipe:, date: 1.month.from_now.to_s, meal: "lunch")
    FactoryBot.create(:meal_plan, date: Date.today.to_s, meal: "lunch")  # from another user
  }

  it 'should list meal plans for user' do
    response = call_tool_with_schema_validation!(tool:, server_context:, token:, start_date: Date.today.to_s, end_date: Date.tomorrow.to_s)

    expect(JSON.parse(response.content.first[:text]).count).to eq(2)
  end

  it 'should not list meal plans for user if start_date is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, end_date: Date.tomorrow)
    end.to(
      raise_error.with_message(/did not contain.+start_date/i)
    )
  end

  it 'should not list meal plans for user if end_date is missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:, start_date: Date.today)
    end.to(
      raise_error.with_message(/did not contain.+end_date/i)
    )
  end
end

