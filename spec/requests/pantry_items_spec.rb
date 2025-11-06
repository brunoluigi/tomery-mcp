require 'rails_helper'

RSpec.describe "PantryItems", type: :request do
  include SignInHelper

  let(:user) { create(:user, active: true) }
  let(:pantry_item) { create(:pantry_item, user: user) }

  before do
    sign_in_as(user)
  end

  describe "GET /index" do
    it "returns http success" do
      get pantry_items_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get new_pantry_item_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new pantry item" do
      expect {
        post pantry_items_path, params: { pantry_item: { name: "Flour", quantity: "500g" } }
      }.to change(PantryItem, :count).by(1)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get edit_pantry_item_path(pantry_item)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates the pantry item" do
      patch pantry_item_path(pantry_item), params: { pantry_item: { name: "Updated Flour", quantity: "1kg" } }
      expect(response).to redirect_to(pantry_items_path)
      pantry_item.reload
      expect(pantry_item.name).to eq("Updated Flour")
    end
  end

  describe "DELETE /destroy" do
    it "destroys the pantry item" do
      pantry_item_to_delete = create(:pantry_item, user: user)
      expect {
        delete pantry_item_path(pantry_item_to_delete)
      }.to change(PantryItem, :count).by(-1)
    end
  end
end
