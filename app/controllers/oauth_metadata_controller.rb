# frozen_string_literal: true

# OAuth 2.0 Protected Resource Metadata (RFC 9728)
# Points to Google as the authorization server for MCP
class OauthMetadataController < ActionController::API
  before_action :set_cors_headers

  # Protected Resource Metadata - RFC 9728
  # https://datatracker.ietf.org/doc/html/rfc9728
  def protected_resource
    if request.method == "OPTIONS"
      head :ok
      return
    end

    # Return protected resource metadata pointing to the authorization server
    render json: {
      resource: request.base_url, # The MCP server base URL
      authorization_servers: [ request.base_url ] # Your server proxies Google OAuth
    }
  end

  # Authorization Server Metadata - RFC 8414
  # Proxies Google's OAuth metadata for MCP clients
  def authorization_server
    if request.method == "OPTIONS"
      head :ok
      return
    end

    render json: {
      issuer: request.base_url, # Your server is the issuer (proxies Google)
      authorization_endpoint: "https://accounts.google.com/o/oauth2/v2/auth",
      token_endpoint: "#{request.base_url}/oauth/token", # Proxy to keep client_secret secure
      registration_endpoint: "#{request.base_url}/oauth/register", # Dynamic Client Registration
      userinfo_endpoint: "https://openidconnect.googleapis.com/v1/userinfo",
      jwks_uri: "https://www.googleapis.com/oauth2/v3/certs",
      response_types_supported: [ "code" ],
      grant_types_supported: [ "authorization_code", "refresh_token" ],
      code_challenge_methods_supported: [ "S256" ],
      scopes_supported: [ "openid", "email", "profile" ],
      token_endpoint_auth_methods_supported: [ "none" ] # Public client with PKCE
    }
  end

  private

  def set_cors_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
  end

  def mcp_server_url
    "#{request.base_url}/mcp"
  end

  def google_authorization_server_url
    "https://accounts.google.com"
  end
end
