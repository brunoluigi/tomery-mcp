require 'rails_helper'

RSpec.describe "recipes/index", type: :view do
  let(:user) { FactoryBot.create(:user) }
  let(:recipes) { [
    FactoryBot.create(:recipe, user:),
    FactoryBot.create(:recipe, user:)
  ] }

  before(:each) do
    assign(:recipes, recipes)
    assign(:query, nil)
    # Define current_user as a helper method for the view
    test_user = user
    def view.current_user
      @current_user
    end
    view.instance_variable_set(:@current_user, test_user)
    allow(test_user).to receive(:pantry_items).and_return(PantryItem.none)
  end

  it "renders a list of recipes" do
    render
    cell_selector = 'div>p'
  end
end
