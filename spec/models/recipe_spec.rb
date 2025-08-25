require 'rails_helper'

RSpec.describe Recipe, type: :model do
  context 'Associations' do
    it { should belong_to(:user) }
    it { should have_many(:meal_plans) }
  end
end
