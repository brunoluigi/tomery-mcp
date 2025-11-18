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
