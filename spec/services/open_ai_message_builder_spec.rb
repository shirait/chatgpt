require 'rails_helper'

RSpec.describe OpenAiMessageBuilder, type: :service do
  describe '.build' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }
    let(:message) { create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id) }

    it 'calls instance method build' do
      builder = instance_double(described_class)
      allow(described_class).to receive(:new).with(message: message).and_return(builder)
      allow(builder).to receive(:build).and_return([])

      described_class.build(message: message)

      expect(builder).to have_received(:build)
    end
  end

  describe '#build' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }

    context 'when send_prev_messages_to_openai_api is false' do
      let(:message) do
        build(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id).tap do |m|
          m.send_prev_messages_to_openai_api = false
        end
      end

      it 'returns only current user message' do
        result = described_class.new(message: message).build

        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result.first).to eq({ role: "user", content: message.content })
      end
    end

    context 'when send_prev_messages_to_openai_api is true and max_prev_message_count is 0' do
      let(:message) do
        build(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id).tap do |m|
          m.send_prev_messages_to_openai_api = true
        end
      end

      before do
        allow(Rails.configuration.static_config).to receive(:max_prev_message_count).and_return(0)
      end

      it 'returns only current user message' do
        result = described_class.new(message: message).build

        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result.first).to eq({ role: "user", content: message.content })
      end
    end

    context 'when send_prev_messages_to_openai_api is true and max_prev_message_count is greater than 0' do
      let(:message) do
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id).tap do |m|
          m.send_prev_messages_to_openai_api = true
        end
      end
      let!(:prev_message1) { create(:message, :assistant, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id, content: 'Previous assistant message') }
      let!(:prev_message2) { create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id, content: 'Previous user message') }

      before do
        allow(Rails.configuration.static_config).to receive(:max_prev_message_count).and_return(5)
      end

      it 'returns previous messages and current user message' do
        result = described_class.new(message: message).build

        expect(result).to be_an(Array)
        expect(result.length).to eq(3)
        # prev_messages.reverseが使われているため、順序が逆になる
        expect(result[0]).to eq({ role: "assistant", content: prev_message1.content })
        expect(result[1]).to eq({ role: "user", content: prev_message2.content })
        expect(result[2]).to eq({ role: "user", content: message.content })
      end
    end

    context 'when message has no attached files' do
      let(:message) do
        build(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id, content: 'Test content').tap do |m|
          m.send_prev_messages_to_openai_api = false
        end
      end

      it 'returns content as string' do
        result = described_class.new(message: message).build

        expect(result.first[:content]).to eq('Test content')
      end
    end

    context 'when message has attached files' do
      let(:message) do
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id, content: 'Test content').tap do |m|
          m.send_prev_messages_to_openai_api = false
        end
      end
      let(:file) { fixture_file_upload('spec/fixtures/test.txt', 'text/plain') }

      before do
        message.message_files.attach(file)
      end

      it 'returns content as array with text and image_url' do
        result = described_class.new(message: message).build

        expect(result.first[:content]).to be_an(Array)
        expect(result.first[:content].first).to include(type: "text", text: "Test content")
        expect(result.first[:content].last).to include(type: "image_url")
        expect(result.first[:content].last[:image_url]).to have_key(:url)
        expect(result.first[:content].last[:image_url][:url]).to match(/^data:text\/plain;base64,/)
      end
    end

    # Note: Messageモデルではcontentが必須のため、空のcontentのテストは省略
    # 実装では`@message.content || ""`となっているが、バリデーションにより空のcontentは許可されない

    context 'when message has attached files with no content_type' do
      let(:message) do
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id, content: 'Test content').tap do |m|
          m.send_prev_messages_to_openai_api = false
        end
      end
      let(:file) { fixture_file_upload('spec/fixtures/test.txt', 'text/plain') }

      before do
        message.message_files.attach(file)
        # content_typeをnilに設定するために、blobを直接操作
        blob = message.message_files.first.blob
        allow(blob).to receive(:content_type).and_return(nil)
        allow(message.message_files.first).to receive(:content_type).and_return(nil)
      end

      it 'uses default content_type image/jpeg' do
        result = described_class.new(message: message).build

        expect(result.first[:content].last[:image_url][:url]).to match(/^data:image\/jpeg;base64,/)
      end
    end
  end
end
