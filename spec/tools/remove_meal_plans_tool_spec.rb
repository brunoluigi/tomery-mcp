require 'rails_helper'

RSpec.describe RemoveMealPlansTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:meal_plan_1) { FactoryBot.create(:meal_plan, user:) }
  let!(:meal_plan_2) { FactoryBot.create(:meal_plan, user:) }
  let!(:meal_plan_3) { FactoryBot.create(:meal_plan, user:) }
  let!(:meal_plan_4) { FactoryBot.create(:meal_plan) }

  it 'should remove meal plans from user calendar' do
    call_tool_with_schema_validation!(tool:, server_context:, token:, ids: [ meal_plan_1.id, meal_plan_2.id ])

    expect(user.meal_plans.count).to eq(1)
  end
  it "should remove meal plans from other user's calendar" do
    call_tool_with_schema_validation!(tool:, server_context:, token:, ids: [ meal_plan_4.id ])

    expect(meal_plan_4.reload).to be_persisted
  end

  it 'should not remove meal plans from user calendar if ids are missing' do
    expect do
      call_tool_with_schema_validation!(tool:, server_context:, token:)
    end.to(
      raise_error
      .with_message(/did not contain.+ids/i)
    )
  end
end
