# frozen_string_literal: true

require "rails_helper"

RSpec.describe AiService do
  describe "#generate_embedding" do
    let(:service) { described_class.new }
    let(:text) { "Test recipe description" }
    let(:mock_response) { instance_double("RubyLLM::EmbeddingResponse", vectors: [ 0.1 ] * 1536) }

    before do
      allow(RubyLLM).to receive(:embed).and_return(mock_response)
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("OPENAI_API_KEY").and_return("test-key")
      allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return(nil)
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

    context "when text is blank" do
      it "raises InvalidRequestError" do
        expect do
          service.generate_embedding("")
        end.to raise_error(AiService::InvalidRequestError, /cannot be blank/)
      end
    end

    context "when API key is missing" do
      before do
        allow(ENV).to receive(:[]).with("OPENAI_API_KEY").and_return(nil)
        allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return(nil)
      end

      it "raises ApiKeyError" do
        expect do
          service.generate_embedding(text)
        end.to raise_error(AiService::ApiKeyError, /AI API key is not configured/)
      end
    end

    context "when Anthropic API key is present" do
      before do
        allow(ENV).to receive(:[]).with("OPENAI_API_KEY").and_return(nil)
        allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return("anthropic-test-key")
      end

      it "generates embedding successfully" do
        result = service.generate_embedding(text)

        expect(RubyLLM).to have_received(:embed).with(text, model: "text-embedding-3-small")
        expect(result).to eq(mock_response.vectors)
      end
    end

    context "when both API keys are present" do
      before do
        allow(ENV).to receive(:[]).with("OPENAI_API_KEY").and_return("openai-test-key")
        allow(ENV).to receive(:[]).with("ANTHROPIC_API_KEY").and_return("anthropic-test-key")
      end

      it "generates embedding successfully" do
        result = service.generate_embedding(text)

        expect(RubyLLM).to have_received(:embed).with(text, model: "text-embedding-3-small")
        expect(result).to eq(mock_response.vectors)
      end
    end

    context "when RubyLLM raises authentication error" do
      let(:error_class) do
        Class.new(StandardError) do
          def self.name
            "RubyLLM::Error"
          end
        end
      end
      let(:error) { error_class.new("Invalid API key") }

      before do
        allow(RubyLLM).to receive(:embed).and_raise(error)
      end

      it "raises ApiKeyError" do
        allow(Rails.logger).to receive(:error)

        expect do
          service.generate_embedding(text)
        end.to raise_error(AiService::ApiKeyError, /Invalid or missing API key/)

        expect(Rails.logger).to have_received(:error).with(/AI Service.*ApiKeyError/)
      end
    end

    context "when RubyLLM raises rate limit error" do
      let(:error_class) do
        Class.new(StandardError) do
          def self.name
            "RubyLLM::Error"
          end
        end
      end
      let(:error) { error_class.new("Rate limit exceeded") }

      before do
        allow(RubyLLM).to receive(:embed).and_raise(error)
      end

      it "raises RateLimitError" do
        allow(Rails.logger).to receive(:error)

        expect do
          service.generate_embedding(text)
        end.to raise_error(AiService::RateLimitError, /Rate limit exceeded/)

        expect(Rails.logger).to have_received(:error).with(/AI Service.*RateLimitError/)
      end
    end

    context "when network error occurs" do
      let(:error_class) do
        # Create a mock error class that matches Faraday::TimeoutError pattern
        Class.new(StandardError) do
          def self.name
            "Faraday::TimeoutError"
          end
        end
      end
      let(:error) { error_class.new("Connection timeout") }

      before do
        allow(RubyLLM).to receive(:embed).and_raise(error)
      end

      it "raises NetworkError" do
        allow(Rails.logger).to receive(:error)

        expect do
          service.generate_embedding(text)
        end.to raise_error(AiService::NetworkError, /Network error/)

        expect(Rails.logger).to have_received(:error).with(/AI Service.*NetworkError/)
      end
    end

    context "when unexpected error occurs" do
      before do
        allow(RubyLLM).to receive(:embed).and_raise(StandardError.new("Unexpected"))
      end

      it "raises Error and logs" do
        allow(Rails.logger).to receive(:error)

        expect do
          service.generate_embedding(text)
        end.to raise_error(AiService::Error, /Unexpected error/)

        expect(Rails.logger).to have_received(:error).with(/AI Service Unexpected Error/)
      end
    end
  end
end
