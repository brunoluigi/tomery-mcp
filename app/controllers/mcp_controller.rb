# frozen_string_literal: true

class McpController < ActionController::API
  before_action :set_cors_headers
  before_action :set_current_user, unless: :public_method?

  attr_reader :current_user

  rescue_from "StandardError" do |exception|
    render(json: { error: "Internal server error" }, status: :internal_server_error)
  end

  def handle
    # Handle CORS preflight
    if request.method == "OPTIONS"
      head :ok
      return
    end

    # These require authentication (handled by before_action)
    render(json: mcp_server.handle_json(request.body.read))
  end

  private

  def mcp_server
    configuration = MCP::Configuration.new
    configuration.exception_reporter = ->(exception, server_context) {
      Rails.logger.error("MCP Error: #{exception.message}")
      Rails.logger.error(exception.backtrace.join("\n"))
    }

    MCP::Server.new(
      name: "tomery_mcp_server",
      version: "1.0.0",
      tools: ApplicationTool.descendants,
      configuration:,
      server_context: { current_user: }
    )
  end

  def public_method?
    method = params[:method]
    method.in?([ "initialize", "notifications/initialized" ]) || !method.to_s.start_with?("tools/", "resources/", "prompts/")
  end

  def set_current_user
    # Extract Bearer token from Authorization header
    auth_header = request.headers["Authorization"]

    Rails.logger.debug("Authorization header: #{auth_header}")

    unless auth_header&.start_with?("Bearer ")
      return render_unauthorized("Missing or invalid Authorization header")
    end

    token = auth_header.sub("Bearer ", "")

    # Find user by MCP token
    @current_user = User.find_by_mcp_token(token)

    unless @current_user
      render_unauthorized("Invalid or expired access token")
    end

    @current_user
  end

  def set_cors_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
  end

  def render_unauthorized(message)
    render(json: {
      jsonrpc: "2.0",
      id: params["id"],
      error: {
        code: -32001,
        message: message
      }
    }, status: :unauthorized)
  end
end
