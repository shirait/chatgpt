require 'rails_helper'

RSpec.describe MessageThread, type: :model do
  describe 'associations' do
    it { should belong_to(:user).with_foreign_key(:creator_id) }
    it { should have_many(:messages).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:creator_id) }
  end

  describe '.build_message_thread' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:params) do
      {
        content: "First line\nSecond line\nThird line"
      }
    end

    it 'creates a new MessageThread instance with the first non-empty line as title' do
      message_thread = described_class.build_message_thread(params: params, creator_id: user.id)

      expect(message_thread).to be_a(MessageThread)
      expect(message_thread).to be_new_record
      expect(message_thread.title).to eq('First line')
      expect(message_thread.creator_id).to eq(user.id)
    end

    context 'when content has empty lines at the beginning' do
      let(:params) do
        {
          content: "\n\nFirst line\nSecond line"
        }
      end

      it 'uses the first non-empty line as title' do
        message_thread = described_class.build_message_thread(params: params, creator_id: user.id)

        expect(message_thread.title).to eq('First line')
      end
    end

    context 'when content has only empty lines' do
      let(:params) do
        {
          content: "\n\n\n"
        }
      end

      it 'sets nil as title' do
        message_thread = described_class.build_message_thread(params: params, creator_id: user.id)

        expect(message_thread.title).to be_nil
      end
    end

    context 'when content is a single line' do
      let(:params) do
        {
          content: 'Single line content'
        }
      end

      it 'uses the single line as title' do
        message_thread = described_class.build_message_thread(params: params, creator_id: user.id)

        expect(message_thread.title).to eq('Single line content')
      end
    end

    context 'when content is empty' do
      let(:params) do
        {
          content: ''
        }
      end

      it 'sets nil as title' do
        message_thread = described_class.build_message_thread(params: params, creator_id: user.id)

        expect(message_thread.title).to be_nil
      end
    end
  end

  describe 'validations - title' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }

    context 'when title is blank' do
      it 'is invalid' do
        message_thread = build(:message_thread, title: '', creator_id: user.id)
        expect(message_thread).not_to be_valid
        expect(message_thread.errors[:title]).to be_present
        expect(message_thread.errors[:title].first).to match(/入力してください/)
      end
    end

    context 'when title is too long' do
      it 'is invalid' do
        long_title = 'a' * 256
        message_thread = build(:message_thread, title: long_title, creator_id: user.id)
        expect(message_thread).not_to be_valid
        expect(message_thread.errors[:title]).to be_present
        expect(message_thread.errors[:title].first).to match(/255文字以内/)
      end
    end

    context 'when title is valid' do
      it 'is valid' do
        message_thread = build(:message_thread, title: 'Valid Title', creator_id: user.id)
        expect(message_thread).to be_valid
      end
    end

    context 'when title is exactly 255 characters' do
      it 'is valid' do
        title = 'a' * 255
        message_thread = build(:message_thread, title: title, creator_id: user.id)
        expect(message_thread).to be_valid
      end
    end
  end

  describe 'validations - creator_id' do
    context 'when creator_id is blank' do
      it 'is invalid' do
        message_thread = build(:message_thread, creator_id: nil)
        expect(message_thread).not_to be_valid
        expect(message_thread.errors[:creator_id]).to be_present
        expect(message_thread.errors[:creator_id].first).to match(/入力してください/)
      end
    end
  end

  describe 'dependent: :destroy' do
    let(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:gpt_model) { create(:gpt_model, creator_id: user.id) }
    let(:message_thread) { create(:message_thread, creator_id: user.id) }

    context 'when messages exist' do
      before do
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id)
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id)
      end

      it 'destroys associated messages when message_thread is destroyed' do
        expect {
          message_thread.destroy
        }.to change { Message.count }.by(-2)
      end
    end

    context 'when no messages exist' do
      it 'allows deletion' do
        destroyed_thread = message_thread.destroy
        expect(destroyed_thread.destroyed?).to be true
        expect(described_class.find_by(id: message_thread.id)).to be_nil
      end
    end
  end
end
