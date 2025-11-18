# frozen_string_literal: true

namespace :recipes do
  desc "Generate embeddings for all recipes with blank embeddings"
  task generate_embeddings: :environment do
    recipes = Recipe.where(embedding: nil)

    if recipes.empty?
      puts "No recipes with blank embeddings found."
      next
    end

    puts "Found #{recipes.count} recipes with blank embeddings."
    puts "Generating embeddings..."

    recipes.find_each do |recipe|
      puts "  Generating embedding for: #{recipe.title}"
      GenerateRecipeEmbeddingJob.perform_now(recipe.id)
      puts "    ✓ Done"
    end

    puts "\nDone! Generated embeddings for #{recipes.count} recipes."
  end
end
