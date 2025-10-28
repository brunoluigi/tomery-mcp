require 'rails_helper'

RSpec.describe "MealPlans", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/meal_plans/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/meal_plans/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/meal_plans/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/meal_plans/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/meal_plans/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
