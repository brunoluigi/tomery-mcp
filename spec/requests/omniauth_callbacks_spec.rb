require 'rails_helper'

RSpec.describe "OmniauthCallbacks", type: :request do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe "GET /auth/google_oauth2/callback" do
    context "with valid OAuth response" do
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: 'test@example.com',
            name: 'Test User',
            image: 'https://example.com/avatar.jpg'
          }
        })
      end

      it "creates a new user and signs them in" do
        expect {
          get '/auth/google_oauth2/callback'
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(session_path)
        expect(flash[:notice]).to eq('Successfully authenticated with Google!')
      end

      it "signs in existing OAuth user" do
        User.create!(
          provider: 'google_oauth2',
          uid: '123456789',
          email_address: 'test@example.com',
          name: 'Test User'
        )

        expect {
          get '/auth/google_oauth2/callback'
        }.not_to change(User, :count)

        expect(response).to redirect_to(session_path)
      end
    end

    context "with invalid OAuth response" do
      before do
        OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      end

      it "redirects to failure endpoint" do
        get '/auth/google_oauth2/callback'

        expect(response).to redirect_to('/auth/failure?message=invalid_credentials&strategy=google_oauth2')
      end
    end
  end

  describe "GET /auth/failure" do
    it "redirects to sign in with error message" do
      get '/auth/failure', params: { message: 'access_denied' }

      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to include('Authentication failed')
    end
  end
end
