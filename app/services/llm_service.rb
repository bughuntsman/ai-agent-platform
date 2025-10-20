# Service to interact with different LLM providers
# Supports OpenAI and Anthropic APIs with a unified interface
#
# Usage:
#   service = LlmService.new(agent)
#   response = service.send_message("Hello!", conversation_history)

class LlmService
  class LlmError < StandardError; end
  class RateLimitError < LlmError; end
  class InvalidRequestError < LlmError; end

  attr_reader :agent

  def initialize(agent)
    @agent = agent
    @provider = agent.llm_provider
    @model = agent.llm_model
  end

  def send_message(user_message, conversation_history = [])
    case @provider
    when 'openai'
      send_openai_request(user_message, conversation_history)
    when 'anthropic'
      send_anthropic_request(user_message, conversation_history)
    else
      raise LlmError, "Unsupported LLM provider: #{@provider}"
    end
  rescue Faraday::TooManyRequestsError => e
    raise RateLimitError, "Rate limit exceeded: #{e.message}"
  rescue Faraday::BadRequestError => e
    raise InvalidRequestError, "Invalid request: #{e.message}"
  rescue Faraday::Error => e
    raise LlmError, "LLM API error: #{e.message}"
  end

  private

  def send_openai_request(user_message, conversation_history)
    messages = build_openai_messages(user_message, conversation_history)

    response = openai_client.post('/v1/chat/completions') do |req|
      req.headers['Authorization'] = "Bearer #{ENV['OPENAI_API_KEY']}"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        model: @model,
        messages: messages,
        temperature: agent.temperature,
        max_tokens: agent.max_tokens
      }.to_json
    end

    body = JSON.parse(response.body)

    {
      content: body.dig('choices', 0, 'message', 'content'),
      tokens_used: body.dig('usage', 'total_tokens') || 0,
      finish_reason: body.dig('choices', 0, 'finish_reason')
    }
  end

  def send_anthropic_request(user_message, conversation_history)
    messages = build_anthropic_messages(user_message, conversation_history)

    response = anthropic_client.post('/v1/messages') do |req|
      req.headers['x-api-key'] = ENV['ANTHROPIC_API_KEY']
      req.headers['anthropic-version'] = '2023-06-01'
      req.headers['content-type'] = 'application/json'
      req.body = {
        model: @model,
        system: agent.system_prompt,
        messages: messages,
        temperature: agent.temperature,
        max_tokens: agent.max_tokens
      }.to_json
    end

    body = JSON.parse(response.body)

    {
      content: body.dig('content', 0, 'text'),
      tokens_used: body.dig('usage', 'input_tokens').to_i + body.dig('usage', 'output_tokens').to_i,
      finish_reason: body['stop_reason']
    }
  end

  def build_openai_messages(user_message, conversation_history)
    messages = [{ role: 'system', content: agent.system_prompt }]

    conversation_history.each do |msg|
      messages << { role: msg[:role], content: msg[:content] }
    end

    messages << { role: 'user', content: user_message }
    messages
  end

  def build_anthropic_messages(user_message, conversation_history)
    messages = []

    conversation_history.each do |msg|
      next if msg[:role] == 'system' # Anthropic uses separate system parameter
      messages << { role: msg[:role], content: msg[:content] }
    end

    messages << { role: 'user', content: user_message }
    messages
  end

  def openai_client
    @openai_client ||= Faraday.new(url: 'https://api.openai.com') do |f|
      f.request :retry, max: 3, interval: 0.5, backoff_factor: 2
      f.adapter Faraday.default_adapter
    end
  end

  def anthropic_client
    @anthropic_client ||= Faraday.new(url: 'https://api.anthropic.com') do |f|
      f.request :retry, max: 3, interval: 0.5, backoff_factor: 2
      f.adapter Faraday.default_adapter
    end
  end
end
