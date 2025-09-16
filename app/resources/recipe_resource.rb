# frozen_string_literal: true

class RecipeResource < ApplicationResource
  # uri "myapp:///users/{token}/recipes/{id}"
  # resource_name "User Recipe"
  # description "User Recipe"
  # mime_type "application/json"


  # def content
  #   token = params[:token]
  #   id = params[:id]

  #   user = User.find_by_mcp_token(token)

  #   JSON.generate(user.recipes.find_by(id:).as_json(only: [ :id, :title, :description, :ingredients, :instructions ]))
  # end
end
