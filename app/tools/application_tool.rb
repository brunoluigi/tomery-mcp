# frozen_string_literal: true

class ApplicationTool < ActionTool::Base
  # write your custom logic to be shared across all tools here

  private

  def find_user_by_token(token)
    user = User.find_by_mcp_token(token)

    raise "Invalid token" unless user

    user
  end

  def current_user
    token = headers.fetch("authorization", "").split(" ").last

    user = User.find_by_mcp_token(token)

    raise "Invalid token" unless user

    user
  end
end
