require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it { should belong_to(:user).with_foreign_key(:creator_id) }
    it { should belong_to(:gpt_model) }
    it { should belong_to(:message_thread) }
  end

  describe 'validations' do
    it { should validate_presence_of(:message_type) }
    it { should validate_presence_of(:gpt_model) }
    it { should validate_presence_of(:message_thread) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:creator_id) }
  end

  describe 'enums' do
    it { should define_enum_for(:message_type).with_values(user: 0, assistant: 1) }
  end

  describe '.build_user_message' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, :active, creator_id: admin_user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }
    let(:params) do
      {
        content: 'Test message content',
        send_prev_messages_to_openai_api: '1'
      }
    end

    before do
      # アクティブなGptModelを設定
      gpt_model
    end

    it 'creates a new Message instance with user type' do
      message = described_class.build_user_message(
        params: params,
        message_thread: message_thread,
        creator_id: user.id
      )

      expect(message).to be_a(Message)
      expect(message).to be_new_record
      expect(message.content).to eq('Test message content')
      expect(message.message_type).to eq('user')
      expect(message.message_thread).to eq(message_thread)
      expect(message.creator_id).to eq(user.id)
      expect(message.gpt_model).to eq(gpt_model)
    end

    it 'sets send_prev_messages_to_openai_api when param is "1"' do
      message = described_class.build_user_message(
        params: params,
        message_thread: message_thread,
        creator_id: user.id
      )

      expect(message.send_prev_messages_to_openai_api?).to be true
    end

    it 'does not set send_prev_messages_to_openai_api when param is not "1"' do
      params[:send_prev_messages_to_openai_api] = '0'
      message = described_class.build_user_message(
        params: params,
        message_thread: message_thread,
        creator_id: user.id
      )

      expect(message.send_prev_messages_to_openai_api?).to be false
    end

    context 'when message_files are present' do
      let(:file) { fixture_file_upload('spec/fixtures/test.txt', 'text/plain') }

      before do
        params[:message_files] = [ file ]
      end

      it 'attaches message files' do
        message = described_class.build_user_message(
          params: params,
          message_thread: message_thread,
          creator_id: user.id
        )

        expect(message.message_files).to be_attached
      end
    end

    context 'when message_files are not present' do
      it 'does not attach message files' do
        message = described_class.build_user_message(
          params: params,
          message_thread: message_thread,
          creator_id: user.id
        )

        expect(message.message_files).not_to be_attached
      end
    end
  end

  describe '#send_prev_messages_to_openai_api?' do
    let(:message) { build(:message) }

    context 'when send_prev_messages_to_openai_api is true' do
      before do
        message.send_prev_messages_to_openai_api = true
      end

      it 'returns true' do
        expect(message.send_prev_messages_to_openai_api?).to be true
      end
    end

    context 'when send_prev_messages_to_openai_api is false' do
      before do
        message.send_prev_messages_to_openai_api = false
      end

      it 'returns false' do
        expect(message.send_prev_messages_to_openai_api?).to be false
      end
    end

    context 'when send_prev_messages_to_openai_api is nil' do
      before do
        message.send_prev_messages_to_openai_api = nil
      end

      it 'returns false' do
        expect(message.send_prev_messages_to_openai_api?).to be false
      end
    end
  end

  describe 'scope :prev_messages' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: admin_user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }
    let!(:message1) { create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id) }
    let!(:message2) { create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id) }
    let!(:message3) { create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id) }
    let!(:message4) { create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id) }
    let(:current_message) { message4 }

    it 'returns previous messages in descending order' do
      prev_messages = described_class.prev_messages(current_message, 3)

      expect(prev_messages).to eq([ message3, message2, message1 ])
    end

    it 'excludes the current message' do
      prev_messages = described_class.prev_messages(current_message, 10)

      expect(prev_messages).not_to include(current_message)
    end

    it 'respects the limit parameter' do
      prev_messages = described_class.prev_messages(current_message, 2)

      expect(prev_messages.count).to eq(2)
      expect(prev_messages).to eq([ message3, message2 ])
    end

    context 'when there are messages in different threads' do
      let(:other_thread) { create(:message_thread, creator_id: user.id) }
      let!(:other_message) { create(:message, message_thread: other_thread, gpt_model: gpt_model, creator_id: user.id) }

      it 'only returns messages from the same thread' do
        prev_messages = described_class.prev_messages(current_message, 10)

        expect(prev_messages).not_to include(other_message)
      end
    end
  end

  describe 'validations - message_type' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: admin_user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }

    context 'when message_type is blank' do
      it 'is invalid' do
        message = build(:message, message_type: nil, gpt_model: gpt_model, message_thread: message_thread, creator_id: user.id)
        expect(message).not_to be_valid
        expect(message.errors[:message_type]).to be_present
      end
    end

    # Note: enumでは無効な値を直接設定できないため、このテストは省略
    # enumのバリデーションはRailsが自動的に行う

    context 'when message_type is valid' do
      it 'is valid for user type' do
        message = build(:message, message_type: :user, gpt_model: gpt_model, message_thread: message_thread, creator_id: user.id)
        expect(message).to be_valid
      end

      it 'is valid for assistant type' do
        message = build(:message, :assistant, gpt_model: gpt_model, message_thread: message_thread, creator_id: user.id)
        expect(message).to be_valid
      end
    end
  end

  describe 'validations - content' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: admin_user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }

    context 'when content is blank' do
      it 'is invalid' do
        message = build(:message, content: '', gpt_model: gpt_model, message_thread: message_thread, creator_id: user.id)
        expect(message).not_to be_valid
        expect(message.errors[:content]).to be_present
        expect(message.errors[:content].first).to match(/入力してください/)
      end
    end

    context 'when content is present' do
      it 'is valid' do
        message = build(:message, content: 'Valid content', gpt_model: gpt_model, message_thread: message_thread, creator_id: user.id)
        expect(message).to be_valid
      end
    end
  end

  describe 'validations - gpt_model' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }

    context 'when gpt_model is nil' do
      it 'is invalid' do
        message = build(:message, gpt_model: nil, message_thread: message_thread, creator_id: user.id)
        expect(message).not_to be_valid
        expect(message.errors[:gpt_model]).to be_present
      end
    end
  end

  describe 'validations - message_thread' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: admin_user.id) }

    context 'when message_thread is nil' do
      it 'is invalid' do
        message = build(:message, message_thread: nil, gpt_model: gpt_model, creator_id: user.id)
        expect(message).not_to be_valid
        expect(message.errors[:message_thread]).to be_present
      end
    end
  end

  describe 'validations - creator_id' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: admin_user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }

    context 'when creator_id is blank' do
      it 'is invalid' do
        message = build(:message, creator_id: nil, gpt_model: gpt_model, message_thread: message_thread)
        expect(message).not_to be_valid
        expect(message.errors[:creator_id]).to be_present
        expect(message.errors[:creator_id].first).to match(/入力してください/)
      end
    end
  end
end
