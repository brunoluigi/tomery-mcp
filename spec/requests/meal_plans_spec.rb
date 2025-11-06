require 'rails_helper'

RSpec.describe "MealPlans", type: :request do
  include SignInHelper

  let(:user) { create(:user, active: true) }
  let(:meal_plan) { create(:meal_plan, user: user) }

  before do
    sign_in_as(user)
  end

  describe "GET /index" do
    it "returns http success" do
      get meal_plans_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get meal_plan_path(meal_plan)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_meal_plan_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new meal plan" do
      recipe = create(:recipe)
      expect {
        post meal_plans_path, params: { meal_plan: { date: Date.today, recipe_id: recipe.id, meal: "breakfast" } }
      }.to change(MealPlan, :count).by(1)
    end
  end

  describe "DELETE /destroy" do
    it "destroys the meal plan" do
      meal_plan_to_delete = create(:meal_plan, user: user)
      expect {
        delete meal_plan_path(meal_plan_to_delete)
      }.to change(MealPlan, :count).by(-1)
    end
  end
end
