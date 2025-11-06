require 'rails_helper'

RSpec.describe "Main", type: :request do
  include SignInHelper

  describe "GET /" do
    context "when not authenticated" do
      it "renders the landing page" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Tomery")
        expect(response.body).to include("Enter the waiting list")
      end
    end

    context "when authenticated" do
      let(:user) { create(:user, active: true) }

      before do
        sign_in_as(user)
      end

      it "renders the RPG menu" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Welcome back, Chef!")
        expect(response.body).to include("Cook something")
        expect(response.body).to include("Discover recipes")
        expect(response.body).to include("Plan meals")
        expect(response.body).to include("Manage pantry")
      end
    end
  end
end
