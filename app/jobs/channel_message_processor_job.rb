# Background job to process incoming messages from different channels
# Enables async processing of Slack, Telegram, SMS, and Web messages

class ChannelMessageProcessorJob
  include Sidekiq::Job

  sidekiq_options queue: 'channels', retry: 5

  def perform(agent_id, channel_type, channel_user_id, message_content, metadata = {})
    agent = Agent.find(agent_id)

    # Find or create conversation
    conversation = ConversationService.find_or_create_conversation(
      agent: agent,
      channel_type: channel_type,
      channel_user_id: channel_user_id,
      metadata: metadata
    )

    # Process the message
    service = ConversationService.new(conversation)
    response = service.process_user_message(message_content)

    # Send response back to the channel
    send_channel_response(channel_type, channel_user_id, response[:content], metadata)

    Rails.logger.info(
      "Processed message from #{channel_type} (#{channel_user_id}). " \
      "Agent: #{agent_id}, Tokens: #{response[:tokens_used]}"
    )
  rescue StandardError => e
    Rails.logger.error("ChannelMessageProcessorJob failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end

  private

  def send_channel_response(channel_type, channel_user_id, content, metadata)
    case channel_type
    when 'slack'
      send_slack_message(channel_user_id, content, metadata)
    when 'telegram'
      send_telegram_message(channel_user_id, content, metadata)
    when 'sms'
      send_sms_message(channel_user_id, content, metadata)
    when 'web'
      send_web_message(channel_user_id, content, metadata)
    end
  end

  def send_slack_message(channel_id, content, metadata)
    # Implement Slack Web API call
    # Faraday.post('https://slack.com/api/chat.postMessage', ...)
    Rails.logger.info("Would send Slack message to #{channel_id}: #{content}")
  end

  def send_telegram_message(chat_id, content, metadata)
    # Implement Telegram Bot API call
    Rails.logger.info("Would send Telegram message to #{chat_id}: #{content}")
  end

  def send_sms_message(phone_number, content, metadata)
    # Implement Twilio SMS API call
    Rails.logger.info("Would send SMS to #{phone_number}: #{content}")
  end

  def send_web_message(user_id, content, metadata)
    # Broadcast via ActionCable or webhook
    Rails.logger.info("Would send Web message to #{user_id}: #{content}")
  end
end
