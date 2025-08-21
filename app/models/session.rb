class Session < ApplicationRecord
  belongs_to :user

  has_secure_token :mcp_token, length: 36
end
