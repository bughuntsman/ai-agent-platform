# == Schema Information
#
# Table name: agent_channels (tenant schema)
#
#  id             :bigint           not null, primary key
#  agent_id       :bigint           not null
#  channel_type   :string           not null (slack, telegram, sms, web)
#  configuration  :jsonb            not null
#  active         :boolean          default(TRUE), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_agent_channels_on_agent_id                  (agent_id)
#  index_agent_channels_on_agent_id_and_channel_type (agent_id,channel_type) UNIQUE
#

class AgentChannel < ApplicationRecord
  # Constants
  CHANNEL_TYPES = %w[slack telegram sms web].freeze

  # Associations
  belongs_to :agent

  # Validations
  validates :channel_type, inclusion: { in: CHANNEL_TYPES }
  validates :channel_type, uniqueness: { scope: :agent_id }
  validate :validate_channel_configuration

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_type, ->(type) { where(channel_type: type) }

  private

  def validate_channel_configuration
    case channel_type
    when 'slack'
      validate_slack_config
    when 'telegram'
      validate_telegram_config
    when 'sms'
      validate_sms_config
    when 'web'
      validate_web_config
    end
  end

  def validate_slack_config
    unless configuration['bot_token'].present? && configuration['signing_secret'].present?
      errors.add(:configuration, "must include bot_token and signing_secret for Slack")
    end
  end

  def validate_telegram_config
    unless configuration['bot_token'].present?
      errors.add(:configuration, "must include bot_token for Telegram")
    end
  end

  def validate_sms_config
    unless configuration['twilio_account_sid'].present? && configuration['twilio_auth_token'].present?
      errors.add(:configuration, "must include Twilio credentials for SMS")
    end
  end

  def validate_web_config
    unless configuration['webhook_url'].present?
      errors.add(:configuration, "must include webhook_url for Web")
    end
  end
end
