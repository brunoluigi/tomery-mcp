# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateRecipeEmbeddingJob, type: :job do
  let(:user) { FactoryBot.create(:user) }
  let(:recipe) do
    FactoryBot.create(
      :recipe,
      user:,
      title: "Pasta Carbonara",
      description: "Classic Italian pasta dish",
      ingredients: [
        { "name" => "Pasta", "quantity" => "400g" },
        { "name" => "Eggs", "quantity" => "3" },
        { "name" => "Bacon", "quantity" => "200g" }
      ],
      instructions: [ "Cook pasta", "Mix eggs", "Combine all" ]
    )
  end
  let(:mock_embedding) { [ 0.1, 0.2, 0.3 ] * 100 } # Mock embedding vector
  let(:ai_service) { instance_double(AiService) }

  before do
    allow(AiService).to receive(:new).and_return(ai_service)
    allow(ai_service).to receive(:generate_embedding).and_return(mock_embedding)
  end

  describe "#perform" do
    it "generates and stores embedding for a recipe" do
      expect(recipe.embedding).to be_nil

      described_class.perform_now(recipe.id)

      recipe.reload
      expect(recipe.embedding).to be_present
    end

    it "regenerates embedding even if one already exists" do
      recipe.update!(embedding: mock_embedding)

      expect(ai_service).to receive(:generate_embedding).and_return(mock_embedding)

      described_class.perform_now(recipe.id)

      recipe.reload
      expect(recipe.embedding).to be_present
    end

    it "handles missing recipe gracefully" do
      expect do
        described_class.perform_now("non-existent-id")
      end.not_to raise_error
    end

    it "builds embedding text from recipe content" do
      expect(ai_service).to receive(:generate_embedding) do |text|
        expect(text).to include("Pasta Carbonara")
        expect(text).to include("Classic Italian pasta dish")
        expect(text).to include("Pasta 400g")
        expect(text).to include("Eggs 3")
        expect(text).to include("Bacon 200g")
        mock_embedding
      end

      described_class.perform_now(recipe.id)
    end

    context "when AI service raises an error" do
      before do
        allow(ai_service).to receive(:generate_embedding).and_raise(StandardError.new("API Error"))
      end

      it "logs error and re-raises" do
        allow(Rails.logger).to receive(:error)

        expect do
          described_class.perform_now(recipe.id)
        end.to raise_error(StandardError, "API Error")

        expect(Rails.logger).to have_received(:error).with(/Failed to generate embedding/)
      end
    end
  end
end
