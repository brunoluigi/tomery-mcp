# frozen_string_literal: true

require "rails_helper"

RSpec.describe "MCP Endpoint", type: :request do
  let(:user) { create(:user) }
  let(:session) { create(:session, user:, mcp_token: "valid_token_123") }
  let(:headers) { { "Content-Type" => "application/json" } }
  let(:auth_headers) { headers.merge("Authorization" => "Bearer valid_token_123") }

  describe "POST /mcp" do
    context "with initialize method" do
      it "returns server capabilities without requiring authentication" do
        request_body = {
          jsonrpc: "2.0",
          id: 1,
          method: "initialize",
          params: {
            protocolVersion: "2024-11-05",
            capabilities: {},
            clientInfo: { name: "test", version: "1.0" }
          }
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["jsonrpc"]).to eq("2.0")
        expect(json["result"]).to be_present
        expect(json["result"]["capabilities"]).to be_present
        expect(json["result"]["serverInfo"]).to be_present
        expect(json["result"]["serverInfo"]["name"]).to eq("tomery_mcp_server")
      end
    end

    context "with notifications/initialized method" do
      it "acknowledges the notification without requiring authentication" do
        request_body = {
          jsonrpc: "2.0",
          method: "notifications/initialized"
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:success)
      end
    end

    context "with tools/list method" do
      it "requires authentication" do
        request_body = {
          jsonrpc: "2.0",
          id: 2,
          method: "tools/list"
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq(-32001)
        expect(json["error"]["message"]).to include("Authorization header")
      end

      it "returns list of tools with valid Bearer token" do
        session # ensure session exists

        request_body = {
          jsonrpc: "2.0",
          id: 2,
          method: "tools/list"
        }.to_json

        post "/mcp", params: request_body, headers: auth_headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["result"]["tools"]).to be_an(Array)
        expect(json["result"]["tools"].length).to be > 0
      end
    end

    context "with tools/call method" do
      it "requires authentication" do
        request_body = {
          jsonrpc: "2.0",
          id: 3,
          method: "tools/call",
          params: {
            name: "ListRecipesTool",
            arguments: {}
          }
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq(-32001)
        expect(json["error"]["message"]).to include("Authorization header")
      end

      it "executes tool with valid Bearer token" do
        session # ensure session exists
        create(:recipe, user:, title: "Test Recipe")

        request_body = {
          jsonrpc: "2.0",
          id: 3,
          method: "tools/call",
          params: {
            name: "ListRecipesTool",
            arguments: {}
          }
        }.to_json

        post "/mcp", params: request_body, headers: auth_headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json).to be_present
        expect(json["jsonrpc"]).to eq("2.0")
      end

      it "rejects invalid Bearer token" do
        request_body = {
          jsonrpc: "2.0",
          id: 3,
          method: "tools/call",
          params: {
            name: "ListRecipesTool",
            arguments: {}
          }
        }.to_json

        invalid_headers = headers.merge("Authorization" => "Bearer invalid_token")
        post "/mcp", params: request_body, headers: invalid_headers

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]["message"]).to include("Invalid or expired access token")
      end
    end

    context "with unknown method" do
      it "returns method not found error" do
        request_body = {
          jsonrpc: "2.0",
          id: 4,
          method: "unknown/method"
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq(-32601)
        expect(json["error"]["message"]).to include("Method not found")
      end
    end

    context "authentication edge cases" do
      it "rejects requests with missing token parameter" do
        session # ensure session exists

        request_body = {
          jsonrpc: "2.0",
          id: 5,
          method: "tools/list",
          params: {
            arguments: {}
          }
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "rejects requests with nil token" do
        request_body = {
          jsonrpc: "2.0",
          id: 6,
          method: "tools/list",
          params: {
            arguments: {
              token: nil
            }
          }
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end

      it "rejects requests with empty token" do
        request_body = {
          jsonrpc: "2.0",
          id: 7,
          method: "tools/list",
          params: {
            arguments: {
              token: ""
            }
          }
        }.to_json

        post "/mcp", params: request_body, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
