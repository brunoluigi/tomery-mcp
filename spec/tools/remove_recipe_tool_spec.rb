require 'rails_helper'

RSpec.describe RemoveRecipeTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:recipe_1) { FactoryBot.create(:recipe, user:) }
  let!(:recipe_2) { FactoryBot.create(:recipe, user:) }
  let!(:recipe_3) { FactoryBot.create(:recipe) }

  it 'should remove recipe from user cookbook' do
    tool.call_with_schema_validation!(token:, id: recipe_1.id)

    expect(user.recipes.count).to eq(1)
  end
  it "should remove recipe from other user's cookbook" do
    tool.call_with_schema_validation!(token:, id: recipe_3.id)

    expect(recipe_3.reload).to be_persisted
  end

  it 'should not remove recipe from user cookbook if id are missing' do
    expect do
      tool.call_with_schema_validation!(token:)
    end.to(
      raise_error(FastMcp::Tool::InvalidArgumentsError)
      .with_message(/id.+is missing/i)
    )
  end
end
