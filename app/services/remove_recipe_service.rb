# frozen_string_literal: true

class RemoveRecipeService < ApplicationTool
  def self.call(user:, id:)
    user.recipes.where(id:).destroy_all
  end
end
