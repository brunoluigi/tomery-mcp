class MainController < ApplicationController
  allow_unauthenticated_access

  def index
    if authenticated?
      render :menu
    end
  end
end
