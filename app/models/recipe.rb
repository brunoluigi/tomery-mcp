class Recipe < ApplicationRecord
  belongs_to :user

  has_many :meal_plans, dependent: :destroy

  has_neighbors :embedding

  after_commit :generate_embedding_async, if: :should_generate_embedding?

  def self.search_by_embedding(query_text, limit: 10, max_distance: 0.7)
    return none if query_text.blank?

    query_embedding = AiService.new.generate_embedding(query_text)

    # Find nearest neighbors and filter by distance threshold
    # Cosine distance: lower = more similar, max_distance threshold filters out dissimilar results
    nearest_neighbors(:embedding, query_embedding, distance: "cosine")
      .where("embedding <=> ? < ?", query_embedding.to_json, max_distance)
      .limit(limit)
  end

  def self.suggest_from_pantry(user, limit: 10, max_distance: 0.7, require_all_ingredients: true)
    pantry_items = user.pantry_items
    return none if pantry_items.empty?

    # Build query text from pantry item names for semantic search
    ingredient_list = pantry_items.pluck(:name).join(", ")
    query_text = "recipes with #{ingredient_list}"

    # Get candidate recipes using embedding search (get more than limit to filter)
    candidate_recipes = search_by_embedding(query_text, limit: limit * 3, max_distance:).to_a

    # Filter to only recipes where user has required ingredients
    pantry_names = normalize_ingredient_names(pantry_items.pluck(:name))
    filtered_ids = candidate_recipes.select do |recipe|
      recipe_ingredients = extract_ingredient_names(recipe)
      next false if recipe_ingredients.empty?

      if require_all_ingredients
        # User must have ALL ingredients
        recipe_ingredients.all? { |ingredient| pantry_names.include?(ingredient) }
      else
        # User must have at least 80% of ingredients
        matches = recipe_ingredients.count { |ingredient| pantry_names.include?(ingredient) }
        (matches.to_f / recipe_ingredients.length) >= 0.8
      end
    end.first(limit).map(&:id)

    # Return as ActiveRecord relation
    where(id: filtered_ids).limit(limit)
  end

  def self.extract_ingredient_names(recipe)
    return [] unless recipe.ingredients.is_a?(Array)

    recipe.ingredients.map do |ingredient|
      if ingredient.is_a?(Hash)
        ingredient["name"] || ingredient[:name] || ingredient["ingredient"] || ingredient[:ingredient]
      else
        ingredient.to_s
      end
    end.compact.map { |name| normalize_ingredient_name(name) }
  end

  def self.normalize_ingredient_names(names)
    names.map { |name| normalize_ingredient_name(name) }.to_set
  end

  def self.normalize_ingredient_name(name)
    name.to_s.downcase.strip
  end

  private

  def should_generate_embedding?
    return false unless relevant_fields_present?

    # Generate if no embedding exists, or if relevant fields changed
    embedding.blank? || relevant_fields_changed?
  end

  def relevant_fields_changed?
    saved_change_to_title? || saved_change_to_description? || saved_change_to_ingredients?
  end

  def relevant_fields_present?
    title.present? || description.present? || ingredients.present?
  end

  def generate_embedding_async
    GenerateRecipeEmbeddingJob.perform_later(id)
  end
end
