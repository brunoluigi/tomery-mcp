require 'rails_helper'

RSpec.describe "/passwords", type: :request do
  include SignInHelper

  describe "GET /new" do
    it "renders a successful response" do
      get new_password_url
      expect(response).to be_successful
    end
  end

  describe "POST /" do
    it "renders a successful response" do
      user = FactoryBot.create(:user, active: true)

      post passwords_url, params: { email_address: user.email_address }

      expect(response).to redirect_to(new_session_url)
    end

    it "renders a successful response for invalid email address" do
      post passwords_url, params: { email_address: "test@test.com" }

      expect(response).to redirect_to(new_session_url)
    end
  end

  describe "GET /:token/edit" do
    context "with valid parameters" do
      it "renders the edit page" do
        user = FactoryBot.create(:user, active: true)

        get edit_password_url(user.password_reset_token)

        expect(response).to be_successful
      end

      it "redirects to the session page" do
        get edit_password_url("invalid token")

        expect(response).to redirect_to(new_password_url)
      end
    end
  end

  describe "PUT /:token" do
    it "updates the password" do
      user = FactoryBot.create(:user, active: true, password: "old password")

      put password_url(token: user.password_reset_token), params: { password: "new password", password_confirmation: "new password" }

      expect(response).to redirect_to(new_session_url)

      expect(User.active.authenticate_by(email_address: user.email_address, password: "new password")).to eq(user)
    end

    it "redirects to the new session page if invalid token" do
      put password_url(token: 'invalid token'), params: { password: "new password", password_confirmation: "new password" }

      expect(response).to redirect_to(new_password_url)
    end
  end
end
