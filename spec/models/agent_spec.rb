require 'rails_helper'

RSpec.describe Agent, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:llm_provider) }
    it { should validate_presence_of(:llm_model) }
    it { should validate_presence_of(:system_prompt) }
    it { should validate_inclusion_of(:llm_provider).in_array(Agent::LLM_PROVIDERS) }
  end

  describe 'associations' do
    it { should have_many(:conversations).dependent(:destroy) }
    it { should have_many(:agent_channels).dependent(:destroy) }
  end

  describe 'scopes' do
    let!(:active_agent) { create(:agent, active: true) }
    let!(:inactive_agent) { create(:agent, active: false) }

    it 'returns only active agents' do
      expect(Agent.active).to include(active_agent)
      expect(Agent.active).not_to include(inactive_agent)
    end
  end

  describe '#execute_prompt_sync' do
    let(:agent) { create(:agent, :openai) }

    it 'sends message to LLM service' do
      allow_any_instance_of(LlmService).to receive(:send_message).and_return({
        content: 'Hello!',
        tokens_used: 10,
        finish_reason: 'stop'
      })

      response = agent.execute_prompt_sync('Hi there')

      expect(response[:content]).to eq('Hello!')
      expect(response[:tokens_used]).to eq(10)
    end
  end
end
