# frozen_string_literal: true

class Tools::RemoveRecipeService
  def self.call(user:, id:)
    user.recipes.where(id:).destroy_all
  end
end
