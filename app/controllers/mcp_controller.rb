# frozen_string_literal: true

class McpController < ActionController::API
  before_action :set_current_user, if: :tools_call?

  attr_reader :current_user

  rescue_from "StandardError" do |exception|
    render(json: { error: "Internal server error" }, status: :internal_server_error)
  end

  def handle
    if params[:method] == "notifications/initialized"
      head :accepted
    else
      render(json: mcp_server.handle_json(request.body.read))
    end
  end

  private

  def mcp_server
    configuration = MCP::Configuration.new
    configuration.exception_reporter = ->(exception, server_context) {
      pp exception
      pp server_context
    }

    MCP::Server.new(
      name: "rails_mcp_server",
      version: "1.0.0",
      tools: ApplicationTool.descendants,
      configuration:,
      server_context: { current_user: }
    )
  end

  private

  def tools_call?
    params.dig("method") == "tools/call"
  end

  def set_current_user
    id = params["id"]
    token = params.dig("params", "arguments", "token")

    @current_user = User.find_by_mcp_token(token)

    render(json: { jsonrpc: "2.0", id:, error: { code: 1001, message: "Invalid token" } }, status: :unauthorized) unless @current_user

    @current_user
  end
end
