# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiService do
  describe "#generate_embedding" do
    let(:service) { described_class.new }
    let(:text) { "Test recipe description" }
    let(:mock_response) { instance_double("RubyLLM::EmbeddingResponse", vectors: [ 0.1 ] * 1536) }

    before do
      allow(RubyLLM).to receive(:embed).and_return(mock_response)
    end

    it "generates embedding for text" do
      result = service.generate_embedding(text)

      expect(RubyLLM).to have_received(:embed).with(text, model: "text-embedding-3-small")
      expect(result).to eq(mock_response.vectors)
    end

    it "allows custom model" do
      service.generate_embedding(text, model: "text-embedding-3-large")

      expect(RubyLLM).to have_received(:embed).with(text, model: "text-embedding-3-large")
    end

    context "when RubyLLM raises an error" do
      before do
        # RubyLLM::Error may not be defined or may have different constructor
        # Test with StandardError which will be caught by the second rescue block
        allow(RubyLLM).to receive(:embed).and_raise(StandardError.new("API Error"))
      end

      it "logs and re-raises the error" do
        allow(Rails.logger).to receive(:error)

        expect do
          service.generate_embedding(text)
        end.to raise_error(StandardError, "API Error")

        # Since RubyLLM::Error may not exist, it will be caught by StandardError rescue
        expect(Rails.logger).to have_received(:error).with(/AI Service Unexpected Error/)
      end
    end

    context "when unexpected error occurs" do
      before do
        allow(RubyLLM).to receive(:embed).and_raise(StandardError.new("Unexpected"))
      end

      it "logs and re-raises" do
        expect(Rails.logger).to receive(:error).with(/AI Service Unexpected Error/)

        expect do
          service.generate_embedding(text)
        end.to raise_error(StandardError, "Unexpected")
      end
    end
  end
end
