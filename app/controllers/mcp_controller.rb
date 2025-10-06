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

    method = params[:method]

    case method
    when "initialize"
      # Initialize is public - no auth required
      render(json: mcp_server.handle_json(request.body.read))
    when "notifications/initialized"
      # Notification that client has initialized - acknowledge it
      head :accepted
    when "tools/list", "tools/call"
      # These require authentication (handled by before_action)
      render(json: mcp_server.handle_json(request.body.read))
    else
      # Unknown method
      render(json: {
        jsonrpc: "2.0",
        id: params[:id],
        error: {
          code: -32601,
          message: "Method not found: #{method}"
        }
      }, status: :not_found)
    end
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
    # Extract Bearer token from Authorization header (OAuth 2.1 Section 5.1.1)
    auth_header = request.headers["Authorization"]

    unless auth_header&.start_with?("Bearer ")
      return render_unauthorized("Missing or invalid Authorization header")
    end

    token = auth_header.sub("Bearer ", "")

    # Validate Google OAuth token
    user_info = validate_google_token(token)
    unless user_info
      return render_unauthorized("Invalid or expired access token")
    end

    # Find or create user from Google OAuth token
    @current_user = User.find_by(email_address: user_info["email"])

    unless @current_user
      render_unauthorized("User not found")
    end

    @current_user
  end

  def validate_google_token(token)
    # Validate Google ID token
    validator = GoogleIDToken::Validator.new
    begin
      payload = validator.check(token, ENV["GOOGLE_CLIENT_ID"])
      return nil unless payload

      {
        "email" => payload["email"],
        "name" => payload["name"],
        "picture" => payload["picture"]
      }
    rescue GoogleIDToken::ValidationError => e
      Rails.logger.error("Google token validation error: #{e.message}")
      nil
    end
  end

  def set_cors_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
  end

  def render_unauthorized(message)
    # Add WWW-Authenticate header per RFC 9728 Section 5.1
    response.headers["WWW-Authenticate"] = 'Bearer realm="MCP Server", ' \
      "resource_metadata=\"#{request.base_url}/.well-known/oauth-protected-resource\""

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
