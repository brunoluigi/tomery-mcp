require 'rails_helper'

RSpec.describe RemoveRecipeTool do
  include MCP::Tool::TestHelper

  subject(:tool) { described_class }
  let(:user) { FactoryBot.create(:user) }
  let(:server_context) { { current_user: user } }
  let(:token) { user.sessions.create!.mcp_token }
  let!(:recipe_1) { FactoryBot.create(:recipe, user: user) }
  let!(:recipe_2) { FactoryBot.create(:recipe, user: user) }
  let!(:recipe_3) { FactoryBot.create(:recipe) }

  it 'should remove recipe from user cookbook' do
    call_tool_with_schema_validation!(tool: tool, server_context: server_context, token: token, id: recipe_1.id)

    expect(user.recipes.count).to eq(1)
  end
  it "should remove recipe from other user's cookbook" do
    call_tool_with_schema_validation!(tool: tool, server_context: server_context, token: token, id: recipe_3.id)

    expect(recipe_3.reload).to be_persisted
  end

  it 'should not remove recipe from user cookbook if id are missing' do
    expect do
      call_tool_with_schema_validation!(tool: tool, server_context: server_context, token: token)
    end.to(
      raise_error
      .with_message(/did not contain.+id/i)
    )
  end
end
