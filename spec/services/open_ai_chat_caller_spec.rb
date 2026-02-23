require 'rails_helper'

RSpec.describe OpenAiChatCallerHttp, type: :service do
  describe '#call!' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, :active, creator_id: user.id, updater_id: admin_user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }
    let(:user_message) do
      create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id, content: 'Test message')
    end

    before do
      # テスト環境ではstubを使用する設定
      allow(Rails.configuration.static_config).to receive(:use_openai_stub).and_return(true)
      allow(Rails.env).to receive(:development?).and_return(true)
    end

    it 'creates an assistant message' do
      # user_messageはletで既に作成されているため、assistantメッセージのみをカウント
      expect {
        described_class.new(message_thread: message_thread, user_message: user_message).call!
      }.to change { Message.where(message_type: :assistant).count }.by(1)

      assistant_message = Message.last
      expect(assistant_message.message_type).to eq('assistant')
      expect(assistant_message.message_thread).to eq(message_thread)
      expect(assistant_message.gpt_model).to eq(gpt_model)
      expect(assistant_message.creator_id).to eq(user.id)
    end

    it 'uses stub response in development environment when stub is enabled' do
      allow(Rails.env).to receive(:development?).and_return(true)
      allow(Rails.configuration.static_config).to receive(:use_openai_stub).and_return(true)

      described_class.new(message_thread: message_thread, user_message: user_message).call!

      assistant_message = Message.last
      expect(assistant_message.content).to include('Hello, world!(stub message for:')
      expect(assistant_message.content).to include('Test message')
    end

    context 'when ENV USE_OPENAI_STUB is set to true and in development environment' do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("USE_OPENAI_STUB").and_return("true")
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(Rails.configuration.static_config).to receive(:use_openai_stub).and_return(false)
      end

      it 'uses stub response' do
        described_class.new(message_thread: message_thread, user_message: user_message).call!

        assistant_message = Message.last
        expect(assistant_message.content).to include('Hello, world!(stub message for:')
      end
    end

    context 'when stub is not used' do
      let(:mock_client) { instance_double(OpenAI::Client) }
      let(:mock_response) do
        {
          "choices" => [
            {
              "message" => {
                "content" => "This is a test response from OpenAI"
              }
            }
          ]
        }
      end

      before do
        allow(Rails.env).to receive(:development?).and_return(false)
        allow(Rails.configuration.static_config).to receive(:use_openai_stub).and_return(false)
        allow(Rails.configuration.static_config).to receive(:openai_key).and_return('test-key')
        allow(Rails.configuration.static_config).to receive(:use_http_call).and_return(true)
        allow(OpenAI::Client).to receive(:new).with(access_token: 'test-key').and_return(mock_client)
        allow(mock_client).to receive(:chat).and_return(mock_response)
        allow(OpenAiMessageBuilder).to receive(:build).and_return([ { role: "user", content: "Test message" } ])
      end

      it 'calls OpenAI API and creates message with response content' do
        described_class.new(message_thread: message_thread, user_message: user_message).call!

        assistant_message = Message.last
        expect(assistant_message.content).to eq("This is a test response from OpenAI")
        expect(mock_client).to have_received(:chat).with(
          parameters: {
            model: gpt_model.name,
            messages: [ { role: "user", content: "Test message" } ],
            temperature: gpt_model.temperature
          }
        )
      end
    end

    context 'when message content is longer than 50 characters' do
      let(:admin_user) { create(:user, :admin, :self_referential) }
      let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
      let(:user_message) do
        long_content = 'a' * 100
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id, content: long_content)
      end

      before do
        allow(Rails.env).to receive(:development?).and_return(true)
        allow(Rails.configuration.static_config).to receive(:use_openai_stub).and_return(true)
      end

      it 'truncates content in stub response' do
        described_class.new(message_thread: message_thread, user_message: user_message).call!

        assistant_message = Message.last
        expect(assistant_message.content).to include('a' * 50)
        expect(assistant_message.content).to include('...')
      end
    end
  end
end
