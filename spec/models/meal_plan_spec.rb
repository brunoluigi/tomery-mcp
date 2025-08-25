require 'rails_helper'

RSpec.describe MealPlan, type: :model do
  context 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:recipe) }
  end
end
