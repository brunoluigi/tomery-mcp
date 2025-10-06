# frozen_string_literal: true

# OAuth Token Proxy - exchanges authorization codes with Google
# This keeps the client_secret secure on the server side
class OauthProxyController < ActionController::API
  before_action :set_cors_headers

  # Token endpoint proxy - exchanges code for tokens with Google
  def token
    if request.method == "OPTIONS"
      head :ok
      return
    end

    # Forward the token request to Google with our client_secret
    response = HTTParty.post(
      "https://oauth2.googleapis.com/token",
      body: {
        code: params[:code],
        client_id: ENV["GOOGLE_CLIENT_ID"],
        client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        redirect_uri: params[:redirect_uri],
        grant_type: params[:grant_type] || "authorization_code",
        code_verifier: params[:code_verifier]
      }.compact
    )

    if response.success?
      render json: response.parsed_response
    else
      render json: response.parsed_response, status: response.code
    end
  end

  private

  def set_cors_headers
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization"
  end
end
