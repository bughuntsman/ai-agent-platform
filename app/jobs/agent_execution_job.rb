# Background job to execute agent prompts asynchronously
# Enables non-blocking LLM API calls for better UX

class AgentExecutionJob
  include Sidekiq::Job

  sidekiq_options queue: 'default', retry: 3

  def perform(agent_id, user_message, conversation_id = nil)
    agent = Agent.find(agent_id)

    conversation = if conversation_id
                     Conversation.find(conversation_id)
                   else
                     # Create a temporary conversation for one-off executions
                     Conversation.create!(
                       agent: agent,
                       channel_type: 'web',
                       channel_user_id: 'system',
                       metadata: { source: 'job' }
                     )
                   end

    service = ConversationService.new(conversation)
    response = service.process_user_message(user_message)

    # Log successful execution
    Rails.logger.info("Agent #{agent_id} executed successfully. Tokens used: #{response[:tokens_used]}")

    # Broadcast response via ActionCable or webhook (implement as needed)
    # ConversationChannel.broadcast_to(conversation, response)

    response
  rescue StandardError => e
    Rails.logger.error("AgentExecutionJob failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end
end
