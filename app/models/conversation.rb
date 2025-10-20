# == Schema Information
#
# Table name: conversations (tenant schema)
#
#  id              :bigint           not null, primary key
#  agent_id        :bigint           not null
#  channel_type    :string           not null (slack, telegram, sms, web)
#  channel_user_id :string           not null
#  metadata        :jsonb            not null
#  status          :string           default("active"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_conversations_on_agent_id                        (agent_id)
#  index_conversations_on_channel_type_and_channel_user   (channel_type,channel_user_id)
#  index_conversations_on_status                          (status)
#

class Conversation < ApplicationRecord
  # Constants
  CHANNEL_TYPES = %w[slack telegram sms web].freeze
  STATUSES = %w[active paused archived].freeze

  # Associations
  belongs_to :agent
  has_many :messages, dependent: :destroy

  # Validations
  validates :channel_type, inclusion: { in: CHANNEL_TYPES }
  validates :channel_user_id, presence: true
  validates :status, inclusion: { in: STATUSES }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :by_channel, ->(channel) { where(channel_type: channel) }
  scope :recent, -> { order(updated_at: :desc) }

  # Instance methods
  def add_message(role:, content:, tokens_used: 0)
    messages.create!(
      role: role,
      content: content,
      tokens_used: tokens_used
    )
  end

  def message_history(limit: 20)
    messages.order(created_at: :asc).last(limit).map do |msg|
      {
        role: msg.role,
        content: msg.content
      }
    end
  end

  def total_tokens
    messages.sum(:tokens_used)
  end

  def archive!
    update!(status: 'archived')
  end

  def pause!
    update!(status: 'paused')
  end

  def activate!
    update!(status: 'active')
  end
end
