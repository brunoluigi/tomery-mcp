# frozen_string_literal: true

class UserResource < ApplicationResource
  # uri "myapp:///users/{token}"
  # resource_name "Current User"
  # description "Current User"
  # mime_type "application/json"


  # def content
  #   token = params[:token]

  #   user = User.find_by_mcp_token(token)

  #   JSON.generate(user.as_json(only: [ :email_address ]))
  # end
end
