class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :pantry_items, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.find_by_mcp_token(mcp_token)
    joins(:sessions).find_by(sessions: { mcp_token: })
  end
end
