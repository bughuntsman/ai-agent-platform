module Api
  module V1
    class ConversationsController < ApplicationController
      before_action :set_conversation, only: [:show, :update, :messages, :send_message]
      before_action :set_agent, only: [:index, :create]

      # GET /api/v1/agents/:agent_id/conversations
      def index
        @conversations = @agent.conversations.recent.limit(50)

        render json: {
          conversations: @conversations.map { |conv| conversation_json(conv) },
          meta: {
            total: @agent.conversations.count,
            returned: @conversations.count
          }
        }
      end

      # GET /api/v1/conversations/:id
      def show
        render json: { conversation: conversation_json(@conversation) }
      end

      # POST /api/v1/agents/:agent_id/conversations
      def create
        @conversation = @agent.conversations.new(conversation_params)

        if @conversation.save
          render json: { conversation: conversation_json(@conversation) }, status: :created
        else
          render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/conversations/:id
      def update
        if @conversation.update(conversation_params)
          render json: { conversation: conversation_json(@conversation) }
        else
          render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/conversations/:id/messages
      def messages
        @messages = @conversation.messages.chronological.limit(100)

        render json: {
          messages: @messages.map { |msg| message_json(msg) },
          meta: {
            total: @conversation.messages.count,
            total_tokens: @conversation.total_tokens
          }
        }
      end

      # POST /api/v1/conversations/:id/messages
      # Send a message and get AI response
      def send_message
        user_message = params[:content]

        if user_message.blank?
          return render json: { error: 'Message content is required' }, status: :bad_request
        end

        service = ConversationService.new(@conversation)
        response = service.process_user_message(user_message)

        render json: {
          message: message_json(response[:message]),
          content: response[:content],
          tokens_used: response[:tokens_used]
        }
      rescue LlmService::RateLimitError => e
        render json: { error: 'Rate limit exceeded', message: e.message }, status: :too_many_requests
      rescue LlmService::LlmError => e
        render json: { error: 'LLM service error', message: e.message }, status: :service_unavailable
      end

      private

      def set_agent
        @agent = Agent.find(params[:agent_id])
      end

      def set_conversation
        @conversation = Conversation.find(params[:id])
      end

      def conversation_params
        params.require(:conversation).permit(
          :channel_type,
          :channel_user_id,
          :status,
          metadata: {}
        )
      end

      def conversation_json(conversation)
        {
          id: conversation.id,
          agent_id: conversation.agent_id,
          agent_name: conversation.agent.name,
          channel_type: conversation.channel_type,
          channel_user_id: conversation.channel_user_id,
          status: conversation.status,
          metadata: conversation.metadata,
          messages_count: conversation.messages.count,
          total_tokens: conversation.total_tokens,
          created_at: conversation.created_at,
          updated_at: conversation.updated_at
        }
      end

      def message_json(message)
        {
          id: message.id,
          role: message.role,
          content: message.content,
          tokens_used: message.tokens_used,
          created_at: message.created_at
        }
      end
    end
  end
end
