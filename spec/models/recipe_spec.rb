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

  describe '.search_by_embedding' do
    let(:user) { FactoryBot.create(:user) }
    let(:recipe1) { FactoryBot.create(:recipe, user:, title: "Chicken Curry", description: "Spicy chicken dish") }
    let(:recipe2) { FactoryBot.create(:recipe, user:, title: "Beef Stew", description: "Hearty beef dish") }

    before do
      recipe1.update!(embedding: [ 0.1 ] * 1536)
      recipe2.update!(embedding: [ 0.2 ] * 1536)
    end

    it 'returns empty result when query is blank' do
      expect(described_class.search_by_embedding("")).to be_empty
    end

    context 'when AI service fails' do
      before do
        allow_any_instance_of(AiService).to receive(:generate_embedding)
          .and_raise(AiService::Error.new("AI service unavailable"))
      end

      it 'raises the error to allow controller to handle it' do
        expect do
          described_class.search_by_embedding("chicken")
        end.to raise_error(AiService::Error, "AI service unavailable")
      end
    end
  end

  describe '.suggest_from_pantry' do
    let(:user) { FactoryBot.create(:user) }
    let(:recipe1) { FactoryBot.create(:recipe, user:, title: "Chicken Curry", description: "Spicy chicken dish") }
    let(:recipe2) { FactoryBot.create(:recipe, user:, title: "Beef Stew", description: "Hearty beef dish") }

    before do
      recipe1.update!(embedding: [ 0.1 ] * 1536)
      recipe2.update!(embedding: [ 0.2 ] * 1536)
    end

    it 'returns empty result when user has no pantry items' do
      expect(described_class.suggest_from_pantry(user)).to be_empty
    end

    context 'when user has pantry items' do
      let!(:pantry_item1) { FactoryBot.create(:pantry_item, user:, name: "chicken") }
      let!(:pantry_item2) { FactoryBot.create(:pantry_item, user:, name: "rice") }

      before do
        # Mock the embedding generation to return a predictable result
        allow_any_instance_of(AiService).to receive(:generate_embedding) do |_instance, query_text|
          # Return a mock embedding that will match recipe1 (chicken curry)
          [ 0.1 ] * 1536
        end
      end

      it 'calls search_by_embedding with pantry-based query' do
        expect(described_class).to receive(:search_by_embedding)
          .with("recipes with chicken, rice", limit: 10, max_distance: 0.7)
          .and_return(described_class.none)

        described_class.suggest_from_pantry(user)
      end

      it 'allows custom limit and max_distance' do
        expect(described_class).to receive(:search_by_embedding)
          .with("recipes with chicken, rice", limit: 5, max_distance: 0.5)
          .and_return(described_class.none)

        described_class.suggest_from_pantry(user, limit: 5, max_distance: 0.5)
      end
    end

    context 'when AI service fails' do
      let!(:pantry_item) { FactoryBot.create(:pantry_item, user:, name: "chicken") }

      before do
        allow_any_instance_of(AiService).to receive(:generate_embedding)
          .and_raise(AiService::Error.new("AI service unavailable"))
      end

      it 'raises the error to allow controller to handle it' do
        expect do
          described_class.suggest_from_pantry(user)
        end.to raise_error(AiService::Error, "AI service unavailable")
      end
    end
  end
end
