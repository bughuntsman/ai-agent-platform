module Api
  module V1
    class AgentsController < ApplicationController
      before_action :set_agent, only: [:show, :update, :destroy, :execute]

      # GET /api/v1/agents
      def index
        @agents = Agent.all.order(created_at: :desc)

        render json: {
          agents: @agents.map { |agent| agent_json(agent) },
          meta: {
            total: @agents.count
          }
        }
      end

      # GET /api/v1/agents/:id
      def show
        render json: { agent: agent_json(@agent) }
      end

      # POST /api/v1/agents
      def create
        @agent = Agent.new(agent_params)

        if @agent.save
          render json: { agent: agent_json(@agent) }, status: :created
        else
          render json: { errors: @agent.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/agents/:id
      def update
        if @agent.update(agent_params)
          render json: { agent: agent_json(@agent) }
        else
          render json: { errors: @agent.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/agents/:id
      def destroy
        @agent.destroy
        head :no_content
      end

      # POST /api/v1/agents/:id/execute
      # Execute agent with a prompt (async)
      def execute
        user_message = params[:message]
        conversation_id = params[:conversation_id]

        if user_message.blank?
          return render json: { error: 'Message is required' }, status: :bad_request
        end

        # Execute asynchronously
        job_id = @agent.execute_prompt(user_message, conversation_id: conversation_id)

        render json: {
          message: 'Agent execution queued',
          job_id: job_id,
          agent_id: @agent.id
        }, status: :accepted
      end

      private

      def set_agent
        @agent = Agent.find(params[:id])
      end

      def agent_params
        params.require(:agent).permit(
          :name,
          :description,
          :llm_provider,
          :llm_model,
          :system_prompt,
          :temperature,
          :max_tokens,
          :active,
          configuration: {}
        )
      end

      def agent_json(agent)
        {
          id: agent.id,
          name: agent.name,
          description: agent.description,
          llm_provider: agent.llm_provider,
          llm_model: agent.llm_model,
          system_prompt: agent.system_prompt,
          temperature: agent.temperature,
          max_tokens: agent.max_tokens,
          active: agent.active,
          configuration: agent.configuration,
          conversations_count: agent.conversations.count,
          created_at: agent.created_at,
          updated_at: agent.updated_at
        }
      end
    end
  end
end
