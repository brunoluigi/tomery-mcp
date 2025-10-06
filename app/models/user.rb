class User < ApplicationRecord
  has_secure_password validations: false

  has_many :sessions, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :pantry_items, dependent: :destroy
  has_many :meal_plans, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates_presence_of :email_address
  validates_uniqueness_of :email_address
  validates_length_of :password, minimum: 8, allow_nil: true, if: -> { password_digest.present? }

  scope :active, -> { where(active: true) }

  def self.find_by_mcp_token(mcp_token)
    joins(:sessions).find_by(sessions: { mcp_token: })
  end

  # OAuth authentication
  def self.from_omniauth(auth)
    # First, try to find user by provider and uid
    user = where(provider: auth.provider, uid: auth.uid).first

    # If not found, check if a user with this email already exists
    if user.nil?
      user = find_by(email_address: auth.info.email)

      if user
        # Associate the OAuth provider with the existing user
        user.update(
          provider: auth.provider,
          uid: auth.uid,
          name: user.name || auth.info.name,
          image_url: user.image_url || auth.info.image
        )
      else
        # Create a new user
        user = create(
          email_address: auth.info.email,
          name: auth.info.name,
          image_url: auth.info.image,
          provider: auth.provider,
          uid: auth.uid
        )
      end
    end

    user
  end

  def oauth_user?
    provider.present? && uid.present?
  end
end
