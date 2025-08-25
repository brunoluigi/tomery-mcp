require 'rails_helper'

RSpec.describe RemoveMealPlansTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:meal_plan_1) { FactoryBot.create(:meal_plan, user:) }
  let!(:meal_plan_2) { FactoryBot.create(:meal_plan, user:) }
  let!(:meal_plan_3) { FactoryBot.create(:meal_plan, user:) }
  let!(:meal_plan_4) { FactoryBot.create(:meal_plan) }

  it 'should remove meal plans from user calendar' do
    tool.call_with_schema_validation!(token:, ids: [ meal_plan_1.id, meal_plan_2.id ])

    expect(user.meal_plans.count).to eq(1)
  end
  it "should remove meal plans from other user's calendar" do
    tool.call_with_schema_validation!(token:, ids: [ meal_plan_4.id ])

    expect(meal_plan_4.reload).to be_persisted
  end

  it 'should not remove meal plans from user calendar if ids are missing' do
    expect do
      tool.call_with_schema_validation!(token:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/ids.+is missing/i)
    )
  end
end
