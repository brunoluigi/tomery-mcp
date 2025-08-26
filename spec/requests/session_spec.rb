require 'rails_helper'

RSpec.describe "/session", type: :request do
  include SignInHelper

  describe "GET /" do
    it "redirect to login page if not authenticated" do
      get session_url
      expect(response).to redirect_to(new_session_url)
    end

    it "renders a successful response if authenticated" do
      user = FactoryBot.create(:user, active: true, admin: true)

      sign_in_as(user)

      get session_url
      expect(response).to be_successful
    end


    it "redirect to login page if not active" do
      user = FactoryBot.create(:user, active: false)

      sign_in_as(user)

      get session_url
      expect(response).to redirect_to(new_session_url)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_session_url
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new session" do
        user = FactoryBot.create(:user, active: true)
        expect {
          post session_url, params: { email_address: user.email_address, password: user.password }
        }.to change(Session, :count).by(1)
      end

      it "redirects to the session page" do
        user = FactoryBot.create(:user, active: true)

        post session_url, params: { email_address: user.email_address, password: user.password }
        expect(response).to redirect_to(session_url)
      end
    end

    context "with invalid parameters" do
      it "does not create a new session" do
        expect {
          post session_url, params: { email_address: "test@test.com", password: "test" }
        }.to change(Session, :count).by(0)
      end
    end
  end

  describe "DELETE /destroy" do
    it "toggles the requested user active state" do
      user = FactoryBot.create(:user, active: true)

      sign_in_as(user)

      expect {
        delete session_url
      }.to change(Session, :count).by(-1)
    end

    it "redirects to the new session page" do
      user = FactoryBot.create(:user, active: true)

      sign_in_as(user)

      delete session_url
      expect(response).to redirect_to(new_session_url)
    end
  end
end
