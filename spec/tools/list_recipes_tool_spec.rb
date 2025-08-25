require 'rails_helper'

RSpec.describe ListRecipesTool do
  subject(:tool) { described_class.new }
  let(:user) { FactoryBot.create(:user) }
  let(:token) { user.sessions.create!.mcp_token }

  before {
    FactoryBot.create(:recipe, user:)
    FactoryBot.create(:recipe, user:)
    FactoryBot.create(:recipe) # from another user
  }

  it 'should list recipes for user' do
    recipes, _ = tool.call_with_schema_validation!(token:)

    expect(JSON.parse(recipes).count).to eq(2)
  end
end
