# frozen_string_literal: true

class AiService
  class Error < StandardError; end
  class ApiKeyError < Error; end
  class RateLimitError < Error; end
  class NetworkError < Error; end
  class InvalidRequestError < Error; end

  def generate_embedding(text, model: "text-embedding-3-small")
    validate_input(text)
    validate_api_key

    response = RubyLLM.embed(text, model:)
    response.vectors
  rescue ApiKeyError, RateLimitError, NetworkError, InvalidRequestError => e
    # Re-raise our custom errors as-is
    raise
  rescue => e
    # Check if it's a RubyLLM error (by class name or inheritance)
    if e.class.name&.include?("RubyLLM") || (defined?(RubyLLM::Error) && e.is_a?(RubyLLM::Error))
      handle_ruby_llm_error(e)
    # Check for network errors by class name (Faraday may not be loaded in all contexts)
    elsif e.class.name&.match?(/Faraday::(TimeoutError|ConnectionFailed)/)
      handle_network_error(e)
    else
      handle_unexpected_error(e)
    end
  end

  private

  def validate_input(text)
    raise InvalidRequestError, "Text cannot be blank" if text.blank?
  end

  def validate_api_key
    return if ENV["OPENAI_API_KEY"].present?

    raise ApiKeyError, "OpenAI API key is not configured"
  end

  def handle_ruby_llm_error(error)
    error_message = error.message.to_s.downcase

    if error_message.include?("api key") || error_message.include?("authentication") || error_message.include?("unauthorized")
      log_and_raise(ApiKeyError, "Invalid or missing API key: #{error.message}")
    elsif error_message.include?("rate limit") || error_message.include?("too many requests")
      log_and_raise(RateLimitError, "Rate limit exceeded: #{error.message}")
    elsif error_message.include?("invalid") || error_message.include?("bad request")
      log_and_raise(InvalidRequestError, "Invalid request: #{error.message}")
    else
      log_and_raise(Error, "AI API error: #{error.message}")
    end
  end

  def handle_network_error(error)
    log_and_raise(NetworkError, "Network error connecting to AI service: #{error.message}")
  end

  def handle_unexpected_error(error)
    Rails.logger.error("AI Service Unexpected Error: #{error.class} - #{error.message}")
    Rails.logger.error(error.backtrace.join("\n")) if error.backtrace
    raise Error, "Unexpected error: #{error.message}"
  end

  def log_and_raise(error_class, message)
    Rails.logger.error("AI Service #{error_class.name}: #{message}")
    raise error_class, message
  end
end
