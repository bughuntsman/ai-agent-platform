require 'rails_helper'

RSpec.describe LlmService do
  let(:agent) { create(:agent, :openai) }
  let(:service) { described_class.new(agent) }

  describe '#send_message' do
    context 'with OpenAI provider' do
      let(:mock_response) do
        {
          'choices' => [
            {
              'message' => { 'content' => 'Hello from OpenAI!' },
              'finish_reason' => 'stop'
            }
          ],
          'usage' => { 'total_tokens' => 25 }
        }
      end

      before do
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .to_return(
            status: 200,
            body: mock_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'sends request to OpenAI and returns response' do
        response = service.send_message('Hello!')

        expect(response[:content]).to eq('Hello from OpenAI!')
        expect(response[:tokens_used]).to eq(25)
        expect(response[:finish_reason]).to eq('stop')
      end
    end

    context 'with Anthropic provider' do
      let(:agent) { create(:agent, :anthropic) }
      let(:mock_response) do
        {
          'content' => [{ 'text' => 'Hello from Claude!' }],
          'usage' => { 'input_tokens' => 10, 'output_tokens' => 15 },
          'stop_reason' => 'end_turn'
        }
      end

      before do
        stub_request(:post, 'https://api.anthropic.com/v1/messages')
          .to_return(
            status: 200,
            body: mock_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'sends request to Anthropic and returns response' do
        response = service.send_message('Hello!')

        expect(response[:content]).to eq('Hello from Claude!')
        expect(response[:tokens_used]).to eq(25)
        expect(response[:finish_reason]).to eq('end_turn')
      end
    end

    context 'when rate limit is exceeded' do
      before do
        stub_request(:post, 'https://api.openai.com/v1/chat/completions')
          .to_return(status: 429)
      end

      it 'raises RateLimitError' do
        expect {
          service.send_message('Hello!')
        }.to raise_error(LlmService::RateLimitError)
      end
    end
  end
end
