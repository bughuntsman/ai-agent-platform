# == Schema Information
#
# Table name: messages (tenant schema)
#
#  id              :bigint           not null, primary key
#  conversation_id :bigint           not null
#  role            :string           not null (user, assistant, system)
#  content         :text             not null
#  tokens_used     :integer          default(0)
#  metadata        :jsonb            not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#  index_messages_on_role             (role)
#

class Message < ApplicationRecord
  # Constants
  ROLES = %w[user assistant system].freeze

  # Associations
  belongs_to :conversation

  # Validations
  validates :role, inclusion: { in: ROLES }
  validates :content, presence: true
  validates :tokens_used, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :by_role, ->(role) { where(role: role) }
  scope :user_messages, -> { where(role: 'user') }
  scope :assistant_messages, -> { where(role: 'assistant') }
  scope :chronological, -> { order(created_at: :asc) }

  # Instance methods
  def user_message?
    role == 'user'
  end

  def assistant_message?
    role == 'assistant'
  end

  def system_message?
    role == 'system'
  end
end
