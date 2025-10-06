class OmniauthCallbacksController < ApplicationController
  allow_unauthenticated_access
  skip_before_action :verify_authenticity_token, only: :google_oauth2

  def google_oauth2
    auth = request.env["omniauth.auth"]

    user = User.from_omniauth(auth)

    if user.persisted?
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Successfully authenticated with Google!"
    else
      redirect_to new_session_path, alert: "Authentication failed. Please try again."
    end
  end

  def failure
    redirect_to new_session_path, alert: "Authentication failed: #{params[:message]}"
  end
end
