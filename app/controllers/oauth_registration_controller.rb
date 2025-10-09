# frozen_string_literal: true

# OAuth 2.0 Dynamic Client Registration (RFC 7591)
# Returns Google OAuth client credentials for MCP clients
class OauthRegistrationController < ActionController::API
  before_action :set_cors_headers

  # Dynamic Client Registration endpoint
  # Since we proxy Google OAuth, we return the same Google client ID for all clients
  def register
    if request.method == "OPTIONS"
      head :ok
      return
    end

    # Parse the registration request
    registration_params = JSON.parse(request.body.read) rescue {}

    # Validate required Google OAuth environment variables
    unless ENV["GOOGLE_CLIENT_ID"].present?
      return render json: {
        error: "server_error",
        error_description: "OAuth client not configured on server"
      }, status: :internal_server_error
    end

    # Return client registration response per RFC 7591
    # We return the Google OAuth client ID since we're proxying Google
    render json: {
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_id_issued_at: Time.now.to_i,
      # No client_secret for public clients using PKCE
      grant_types: [ "authorization_code", "refresh_token" ],
      response_types: [ "code" ],
      token_endpoint_auth_method: "none", # Public client with PKCE
      redirect_uris: registration_params["redirect_uris"] || [],
      client_name: registration_params["client_name"] || "MCP Client",
      # Additional metadata
      application_type: "web",
      scope: "openid email profile"
    }
  end

  private

  def set_cors_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
  end
end
