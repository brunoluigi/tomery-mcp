FactoryBot.define do
  factory :session do
    user
    mcp_token { SecureRandom.uuid }
  end
end
