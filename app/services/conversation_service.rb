# Service to orchestrate conversations between users and agents
# Handles message creation, LLM execution, and conversation state

class ConversationService
  attr_reader :conversation, :agent

  def initialize(conversation)
    @conversation = conversation
    @agent = conversation.agent
  end

  def process_user_message(content)
    # Save user message
    user_message = conversation.add_message(
      role: 'user',
      content: content
    )

    # Get conversation history for context
    history = conversation.message_history(limit: 20)

    # Call LLM service
    llm_service = LlmService.new(agent)
    response = llm_service.send_message(content, history)

    # Save assistant response
    assistant_message = conversation.add_message(
      role: 'assistant',
      content: response[:content],
      tokens_used: response[:tokens_used]
    )

    # Return response
    {
      message: assistant_message,
      content: response[:content],
      tokens_used: response[:tokens_used]
    }
  rescue LlmService::LlmError => e
    Rails.logger.error("LLM Error in conversation #{conversation.id}: #{e.message}")
    conversation.add_message(
      role: 'system',
      content: "Error: #{e.message}"
    )
    raise
  end

  def self.find_or_create_conversation(agent:, channel_type:, channel_user_id:, metadata: {})
    conversation = Conversation.find_by(
      agent: agent,
      channel_type: channel_type,
      channel_user_id: channel_user_id,
      status: 'active'
    )

    conversation || Conversation.create!(
      agent: agent,
      channel_type: channel_type,
      channel_user_id: channel_user_id,
      metadata: metadata
    )
  end
end
