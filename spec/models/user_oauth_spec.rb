require 'rails_helper'

RSpec.describe User, type: :model do
  describe '.from_omniauth' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: 'test@example.com',
          name: 'Test User',
          image: 'https://example.com/avatar.jpg'
        }
      })
    end

    context 'when user does not exist' do
      it 'creates a new user with OAuth data' do
        expect {
          User.from_omniauth(auth_hash)
        }.to change(User, :count).by(1)

        user = User.last
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
        expect(user.email_address).to eq('test@example.com')
        expect(user.name).to eq('Test User')
        expect(user.image_url).to eq('https://example.com/avatar.jpg')
      end
    end

    context 'when user with same provider and uid already exists' do
      let!(:existing_user) do
        User.create!(
          provider: 'google_oauth2',
          uid: '123456789',
          email_address: 'test@example.com',
          name: 'Test User'
        )
      end

      it 'returns the existing user' do
        expect {
          User.from_omniauth(auth_hash)
        }.not_to change(User, :count)

        user = User.from_omniauth(auth_hash)
        expect(user.id).to eq(existing_user.id)
      end
    end

    context 'when user with same email exists but no OAuth provider' do
      let!(:existing_user) do
        User.create!(
          email_address: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
      end

      it 'associates the OAuth provider with the existing user' do
        expect {
          User.from_omniauth(auth_hash)
        }.not_to change(User, :count)

        user = User.from_omniauth(auth_hash)
        expect(user.id).to eq(existing_user.id)
        expect(user.provider).to eq('google_oauth2')
        expect(user.uid).to eq('123456789')
        expect(user.name).to eq('Test User')
        expect(user.image_url).to eq('https://example.com/avatar.jpg')
      end

      it 'preserves existing user name if present' do
        existing_user.update(name: 'Existing Name')

        user = User.from_omniauth(auth_hash)
        expect(user.name).to eq('Existing Name')
      end
    end
  end

  describe '#oauth_user?' do
    context 'when user has OAuth credentials' do
      let(:user) do
        User.create!(
          provider: 'google_oauth2',
          uid: '123456789',
          email_address: 'oauth@example.com',
          name: 'OAuth User'
        )
      end

      it 'returns true' do
        expect(user.oauth_user?).to be true
      end
    end

    context 'when user does not have OAuth credentials' do
      let(:user) do
        User.create!(
          email_address: 'regular@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
      end

      it 'returns false' do
        expect(user.oauth_user?).to be false
      end
    end
  end

  describe 'password validation' do
    context 'for OAuth users' do
      it 'allows creation without password' do
        user = User.new(
          provider: 'google_oauth2',
          uid: '123456789',
          email_address: 'oauth@example.com',
          name: 'OAuth User'
        )

        expect(user).to be_valid
      end
    end

    context 'for regular users' do
      it 'requires password with minimum length' do
        user = User.new(
          email_address: 'regular@example.com',
          password: 'short'
        )

        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 8 characters)')
      end
    end
  end
end
