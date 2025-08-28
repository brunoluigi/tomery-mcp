# frozen_string_literal: true

class Tools::UpdateRecipeService
  def self.call!(user:, id:, title:, description:, ingredients:, instructions:)
    user.recipes.find_by(id:).update!(title:, description:, ingredients:, instructions:)
  end
end
