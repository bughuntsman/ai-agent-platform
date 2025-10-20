# == Schema Information
#
# Table name: agents (tenant schema)
#
#  id              :bigint           not null, primary key
#  name            :string           not null
#  description     :text
#  llm_provider    :string           not null (openai, anthropic, custom)
#  llm_model       :string           not null
#  system_prompt   :text             not null
#  temperature     :float            default(0.7)
#  max_tokens      :integer          default(1000)
#  configuration   :jsonb            not null
#  active          :boolean          default(TRUE), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_agents_on_active  (active)
#

class Agent < ApplicationRecord
  # Constants
  LLM_PROVIDERS = %w[openai anthropic custom].freeze

  OPENAI_MODELS = %w[gpt-4-turbo gpt-4 gpt-3.5-turbo].freeze
  ANTHROPIC_MODELS = %w[claude-3-opus-20240229 claude-3-sonnet-20240229 claude-3-haiku-20240307].freeze

  # Associations
  has_many :conversations, dependent: :destroy
  has_many :agent_channels, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :llm_provider, inclusion: { in: LLM_PROVIDERS }
  validates :llm_model, presence: true
  validates :system_prompt, presence: true, length: { minimum: 10 }
  validates :temperature, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 2 }
  validates :max_tokens, numericality: { greater_than: 0, less_than_or_equal_to: 100000 }

  validate :validate_model_for_provider

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_provider, ->(provider) { where(llm_provider: provider) }

  # Instance methods
  def execute_prompt(user_message, conversation_id: nil)
    AgentExecutionJob.perform_async(id, user_message, conversation_id)
  end

  def execute_prompt_sync(user_message, conversation_history: [])
    service = LlmService.new(self)
    service.send_message(user_message, conversation_history)
  end

  private

  def validate_model_for_provider
    case llm_provider
    when 'openai'
      unless OPENAI_MODELS.include?(llm_model)
        errors.add(:llm_model, "must be a valid OpenAI model")
      end
    when 'anthropic'
      unless ANTHROPIC_MODELS.include?(llm_model)
        errors.add(:llm_model, "must be a valid Anthropic model")
      end
    end
  end
end
