require 'rails_helper'

RSpec.describe "recipes/show", type: :view do
  before(:each) do
    assign(:recipe, FactoryBot.create(:recipe))
  end

  it "renders attributes in <p>" do
    render
  end
end
