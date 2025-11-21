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

    it 'returns empty result when user has no pantry items' do
      expect(described_class.suggest_from_pantry(user)).to be_empty
    end

    context 'when user has pantry items' do
      let!(:pantry_item1) { FactoryBot.create(:pantry_item, user:, name: "Egg") }
      let!(:pantry_item2) { FactoryBot.create(:pantry_item, user:, name: "Butter") }
      
      # Recipe with only egg (should match)
      let!(:omelet_recipe) do
        FactoryBot.create(
          :recipe,
          user:,
          title: "Omelet",
          description: "Simple omelet",
          ingredients: [{ "name" => "Egg", "quantity" => "2" }]
        )
      end
      
      # Recipe with egg and butter (should match)
      let!(:scrambled_eggs_recipe) do
        FactoryBot.create(
          :recipe,
          user:,
          title: "Scrambled Eggs",
          description: "Scrambled eggs with butter",
          ingredients: [
            { "name" => "Egg", "quantity" => "3" },
            { "name" => "Butter", "quantity" => "1 tbsp" }
          ]
        )
      end
      
      # Recipe with egg but also pasta (should NOT match if require_all_ingredients is true)
      let!(:carbonara_recipe) do
        FactoryBot.create(
          :recipe,
          user:,
          title: "Carbonara",
          description: "Pasta carbonara",
          ingredients: [
            { "name" => "Egg", "quantity" => "2" },
            { "name" => "Pasta", "quantity" => "200g" },
            { "name" => "Bacon", "quantity" => "100g" }
          ]
        )
      end

      before do
        [omelet_recipe, scrambled_eggs_recipe, carbonara_recipe].each do |recipe|
          recipe.update!(embedding: [ 0.1 ] * 1536)
        end
        
        # Mock embedding search to return all three recipes
        allow_any_instance_of(AiService).to receive(:generate_embedding) do |_instance, query_text|
          [ 0.1 ] * 1536
        end
      end

      context 'when require_all_ingredients is true (default)' do
        it 'only returns recipes where user has all ingredients' do
          results = described_class.suggest_from_pantry(user, require_all_ingredients: true)
          result_ids = results.pluck(:id)
          
          expect(result_ids).to include(omelet_recipe.id)
          expect(result_ids).to include(scrambled_eggs_recipe.id)
          expect(result_ids).not_to include(carbonara_recipe.id)
        end
      end

      context 'when require_all_ingredients is false' do
        it 'returns recipes where user has at least 80% of ingredients' do
          results = described_class.suggest_from_pantry(user, require_all_ingredients: false)
          result_ids = results.pluck(:id)
          
          # Carbonara has 3 ingredients, user has 1 (33%), so it should NOT match
          expect(result_ids).not_to include(carbonara_recipe.id)
        end
      end

      it 'handles case-insensitive ingredient matching' do
        # Create recipe with lowercase ingredient
        recipe = FactoryBot.create(
          :recipe,
          user:,
          title: "Test Recipe",
          ingredients: [{ "name" => "egg", "quantity" => "1" }]
        )
        recipe.update!(embedding: [ 0.1 ] * 1536)
        
        results = described_class.suggest_from_pantry(user)
        expect(results.pluck(:id)).to include(recipe.id)
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
