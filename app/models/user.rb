class User < ApplicationRecord
  has_secure_password

  has_many :sessions, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :pantry_items, dependent: :destroy
  has_many :meal_plans, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates_presence_of :email_address
  validates_uniqueness_of :email_address
  validates_length_of :password, minimum: 8, allow_nil: true

  scope :active, -> { where(active: true) }

  def self.find_by_mcp_token(mcp_token)
    joins(:sessions).find_by(sessions: { mcp_token: })
  end
end
