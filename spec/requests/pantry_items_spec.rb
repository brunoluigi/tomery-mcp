require 'rails_helper'

RSpec.describe "PantryItems", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/pantry_items/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/pantry_items/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/pantry_items/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/pantry_items/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/pantry_items/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
