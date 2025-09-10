require 'rails_helper'

RSpec.describe "recipes/index", type: :view do
  before(:each) do
    assign(:recipes, [
      FactoryBot.create(:recipe),
      FactoryBot.create(:recipe)
    ])
  end

  it "renders a list of recipes" do
    render
    cell_selector = 'div>p'
  end
end
