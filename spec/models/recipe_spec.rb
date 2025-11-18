require 'rails_helper'

RSpec.describe Recipe, type: :model do
  include ActiveJob::TestHelper

  context 'Associations' do
    it { should belong_to(:user) }
    it { should have_many(:meal_plans) }
  end

  describe 'embedding generation' do
    let(:user) { FactoryBot.create(:user) }
    let(:recipe) do
      FactoryBot.build(
        :recipe,
        user:,
        title: "Test Recipe",
        description: "A test recipe",
        ingredients: [ { "name" => "Ingredient", "quantity" => "1 cup" } ]
      )
    end

    it 'enqueues embedding job when recipe is created' do
      expect do
        recipe.save!
      end.to have_enqueued_job(GenerateRecipeEmbeddingJob).with(recipe.id)
    end

    it 'enqueues embedding job when title changes' do
      recipe.save!
      recipe.update!(embedding: [ 0.1 ] * 1536)

      expect do
        recipe.update!(title: "New Title")
      end.to have_enqueued_job(GenerateRecipeEmbeddingJob).with(recipe.id)
    end

    it 'enqueues embedding job when description changes' do
      recipe.save!
      recipe.update!(embedding: [ 0.1 ] * 1536)

      expect do
        recipe.update!(description: "New Description")
      end.to have_enqueued_job(GenerateRecipeEmbeddingJob).with(recipe.id)
    end

    it 'enqueues embedding job when ingredients change' do
      recipe.save!
      recipe.update!(embedding: [ 0.1 ] * 1536)

      expect do
        recipe.update!(ingredients: [ { "name" => "New Ingredient", "quantity" => "2 cups" } ])
      end.to have_enqueued_job(GenerateRecipeEmbeddingJob).with(recipe.id)
    end

    it 'regenerates embedding when relevant fields change even if embedding exists' do
      recipe.save!
      recipe.update!(embedding: [ 0.1 ] * 1536)

      expect do
        recipe.update!(title: "New Title")
      end.to have_enqueued_job(GenerateRecipeEmbeddingJob).with(recipe.id)
    end

    it 'does not enqueue job if embedding exists and fields unchanged' do
      recipe.save!
      recipe.update!(embedding: [ 0.1 ] * 1536)

      expect do
        recipe.update!(instructions: [ "New instruction" ])
      end.not_to have_enqueued_job(GenerateRecipeEmbeddingJob)
    end

    it 'does not enqueue job if relevant fields are blank' do
      recipe = FactoryBot.build(
        :recipe,
        user:,
        title: nil,
        description: nil,
        ingredients: nil
      )

      expect do
        recipe.save!
      end.not_to have_enqueued_job(GenerateRecipeEmbeddingJob)
    end
  end
end
