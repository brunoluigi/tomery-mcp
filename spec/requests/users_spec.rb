require 'rails_helper'

RSpec.describe "/users", type: :request do
  include SignInHelper

  describe "GET /index" do
    it "redirect to login page if not authenticated" do
      get users_url
      expect(response).to redirect_to(new_session_url)
    end

    it "renders a successful response if authenticated" do
      user = FactoryBot.create(:user, active: true, admin: true)

      sign_in_as(user)

      get users_url
      expect(response).to be_successful
    end

    it "redirect to session page if not admin" do
      user = FactoryBot.create(:user, active: true, admin: false)

      sign_in_as(user)

      get users_url
      expect(response).to redirect_to(session_url)
    end


    it "redirect to login page if not active" do
      user = FactoryBot.create(:user, active: false)

      sign_in_as(user)

      get users_url
      expect(response).to redirect_to(new_session_url)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_user_url
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        expect {
          post users_url, params: { user: { email_address: "test@test.com" } }
        }.to change(User, :count).by(1)
      end

      it "redirects to the created user" do
        post users_url, params: { user: { email_address: "test@test.com" } }
        expect(response).to redirect_to(users_url)
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post users_url, params: { user: { werid_param: "" } }
        }.to change(User, :count).by(0)
      end
    end
  end

  describe "DELETE /destroy" do
    it "toggles the requested user active state" do
      admin = FactoryBot.create(:user, admin: true, active: true)
      user = FactoryBot.create(:user)

      sign_in_as(admin)

      expect {
        delete user_url(user)
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      admin = FactoryBot.create(:user, admin: true, active: true)
      user = FactoryBot.create(:user)

      sign_in_as(admin)

      delete user_url(user)
      expect(response).to redirect_to(users_url)
    end

    it "redirect to session page if not admin" do
      user = FactoryBot.create(:user, active: true, admin: false)

      sign_in_as(user)

      delete user_url(user)
      expect(response).to redirect_to(session_url)
    end

    it "redirect to login page if not active" do
      user = FactoryBot.create(:user, active: false)

      sign_in_as(user)

      delete user_url(user)
      expect(response).to redirect_to(new_session_url)
    end
  end
  describe "PUT /toggle_active" do
    it "toggles the requested user active state" do
      admin = FactoryBot.create(:user, admin: true, active: true)
      user = FactoryBot.create(:user, active: false)

      sign_in_as(admin)

      expect {
        put toggle_activate_user_url(user)
      }.to change { user.reload.active }
    end

    it "queues user activation mailer" do
      admin = FactoryBot.create(:user, admin: true, active: true)
      user = FactoryBot.create(:user, active: false)

      sign_in_as(admin)

      expect {
        put toggle_activate_user_url(user)
      }.to enqueue_mail(UserMailer, :activated)
    end

    it "redirects to the users list" do
      admin = FactoryBot.create(:user, admin: true, active: true)
      user = FactoryBot.create(:user)

      sign_in_as(admin)

      put toggle_activate_user_url(user)
      expect(response).to redirect_to(users_url)
    end

    it "redirect to session page if not admin" do
      user = FactoryBot.create(:user, active: true, admin: false)

      sign_in_as(user)

      put toggle_activate_user_url(user)
      expect(response).to redirect_to(session_url)
    end

    it "redirect to login page if not active" do
      user = FactoryBot.create(:user, active: false)

      sign_in_as(user)

      put toggle_activate_user_url(user)
      expect(response).to redirect_to(new_session_url)
    end
  end
end
