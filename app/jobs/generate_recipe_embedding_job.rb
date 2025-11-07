# frozen_string_literal: true

class GenerateRecipeEmbeddingJob < ApplicationJob
  queue_as :default

  def perform(recipe_id)
    recipe = Recipe.find(recipe_id)

    embedding_text = build_embedding_text(recipe)
    embedding = AiService.new.generate_embedding(embedding_text)

    recipe.update!(embedding: embedding.to_json)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("Recipe #{recipe_id} not found, skipping embedding generation")
  rescue StandardError => e
    Rails.logger.error("Failed to generate embedding for recipe #{recipe_id}: #{e.message}")
    raise
  end

  private

  def build_embedding_text(recipe)
    parts = [ recipe.title, recipe.description ]

    if recipe.ingredients.is_a?(Array)
      ingredient_list = recipe.ingredients.map do |ingredient|
        if ingredient.is_a?(Hash)
          "#{ingredient['name']} #{ingredient['quantity']}"
        else
          ingredient.to_s
        end
      end.join(", ")
      parts << ingredient_list
    end

    parts.compact.join(". ")
  end
end
