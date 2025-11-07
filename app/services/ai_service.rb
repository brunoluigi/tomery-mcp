# frozen_string_literal: true

class AiService
  def generate_embedding(text, model: "text-embedding-3-small")
    response = RubyLLM.embed(text, model:)
    response.vectors
  rescue RubyLLM::Error => e
    Rails.logger.error("AI Service Error: #{e.message}")
    raise
  rescue StandardError => e
    Rails.logger.error("AI Service Unexpected Error: #{e.message}")
    raise
  end
end
