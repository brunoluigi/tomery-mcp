class Recipe < ApplicationRecord
  belongs_to :user

  has_many :meal_plans, dependent: :destroy

  after_commit :generate_embedding_async, if: :should_generate_embedding?

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
