# frozen_string_literal: true

class UpdateRecipeService < ApplicationTool
  def self.call!(user:, id:, title:, description:, ingredients:, instructions:)
    user.recipes.find_by(id:).update!(title:, description:, ingredients:, instructions:)
  end
end
