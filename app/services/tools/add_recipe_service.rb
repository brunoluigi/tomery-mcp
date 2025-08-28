# frozen_string_literal: true

class Tools::AddRecipeService
  def self.call!(user:, title:, description:, ingredients:, instructions:)
    user.recipes.create!(title:, description:, ingredients:, instructions:)
  end
end
