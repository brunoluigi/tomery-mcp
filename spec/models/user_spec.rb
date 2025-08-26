require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Relations' do
    it { should have_many(:recipes) }
    it { should have_many(:sessions) }
    it { should have_many(:meal_plans) }
    it { should have_many(:pantry_items) }
  end


  describe 'Validation' do
    it { should validate_presence_of(:email_address) }
    it { should validate_length_of(:password).is_at_least(8) }

    context "uniqueness" do
      subject { FactoryBot.build(:user, email_address: "another@email.com") }
      it { should validate_uniqueness_of(:email_address).ignoring_case_sensitivity }
    end
  end

  context 'Normalization' do
    it 'should normalize email_address' do
      user = FactoryBot.create(:user, email_address: 'TEST@TEST.COM ')
      expect(user.email_address).to eq('test@test.com')
    end
  end


  context 'Authentication' do
    it 'should authenticate with valid email and password' do
      user = FactoryBot.create(:user)
      expect(User.authenticate_by(email_address: user.email_address, password: user.password)).to eq(user)
    end

    it 'should not authenticate with invalid email and password' do
      user = FactoryBot.create(:user)
      expect(User.authenticate_by(email_address: user.email_address, password: 'invalid')).to be_nil
    end
  end

  describe '.find_by_mcp_token' do
    it 'should find a user by mcp token' do
      user = FactoryBot.create(:user)
      session = user.sessions.create!

      expect(User.find_by_mcp_token(session.mcp_token)).to eq(user)
    end

    it 'should not find a user by invalid mcp token' do
      expect(User.find_by_mcp_token('invalid')).to be_nil
    end
  end
end
