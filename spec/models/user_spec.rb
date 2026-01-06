require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:message_threads).dependent(:destroy).with_foreign_key(:creator_id) }
    it { should have_many(:messages).dependent(:destroy).with_foreign_key(:creator_id) }
    it { should have_many(:gpt_models).dependent(:destroy).with_foreign_key(:creator_id) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:email).is_at_most(255) }
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).is_at_least(6).is_at_most(128) }
    it { should validate_presence_of(:password_confirmation) }
    it { should validate_length_of(:password_confirmation).is_at_least(6).is_at_most(128) }
    it { should validate_presence_of(:role) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(admin: 0, normal: 1) }
  end

  describe 'validations - email' do
    context 'when email is blank' do
      it 'is invalid' do
        user = build(:user, email: '')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
        expect(user.errors[:email].first).to match(/入力してください/)
      end
    end

    context 'when email is not unique' do
      let!(:existing_user) { create(:user, email: 'test@example.com') }

      it 'is invalid' do
        user = build(:user, email: 'test@example.com')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end
    end

    context 'when email is too long' do
      it 'is invalid' do
        long_email = 'a' * 250 + '@example.com'
        user = build(:user, email: long_email)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
        expect(user.errors[:email].first).to match(/255文字以内/)
      end
    end

    context 'when email format is invalid' do
      it 'is invalid for email without @' do
        user = build(:user, email: 'invalidemail.com')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end

      it 'is invalid for email without domain' do
        user = build(:user, email: 'invalid@')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end

      it 'is invalid for email without local part' do
        user = build(:user, email: '@example.com')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end
    end

    context 'when email format is valid' do
      it 'is valid' do
        user = build(:user, email: 'valid@example.com')
        expect(user).to be_valid
      end
    end

    context 'when email is case insensitive unique' do
      let!(:existing_user) { create(:user, email: 'Test@Example.com') }

      it 'is invalid for same email with different case' do
        user = build(:user, email: 'test@example.com')
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end
    end
  end

  describe 'validations - password' do
    context 'when password is blank' do
      it 'is invalid' do
        user = build(:user, password: '', password_confirmation: '')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
        expect(user.errors[:password].first).to match(/入力してください/)
      end
    end

    context 'when password is too short' do
      it 'is invalid' do
        user = build(:user, password: '12345', password_confirmation: '12345')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
        expect(user.errors[:password].first).to match(/6文字以上/)
      end
    end

    context 'when password is too long' do
      it 'is invalid' do
        long_password = 'a' * 129
        user = build(:user, password: long_password, password_confirmation: long_password)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
        expect(user.errors[:password].first).to match(/128文字以内/)
      end
    end

    context 'when password is valid length' do
      it 'is valid for minimum length' do
        user = build(:user, password: '123456', password_confirmation: '123456')
        expect(user).to be_valid
      end

      it 'is valid for maximum length' do
        password = 'a' * 128
        user = build(:user, password: password, password_confirmation: password)
        expect(user).to be_valid
      end
    end
  end

  describe 'validations - password_confirmation' do
    context 'when password_confirmation is blank' do
      it 'is invalid' do
        user = build(:user, password: 'password', password_confirmation: '')
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to be_present
        expect(user.errors[:password_confirmation].first).to match(/入力してください/)
      end
    end

    # Note: Deviseのデフォルトの動作では、password_confirmationの不一致は
    # passwordフィールドにエラーが追加されることがありますが、
    # このアプリケーションでは明示的なバリデーションがないため、このテストは省略

    context 'when password_confirmation matches password' do
      it 'is valid' do
        user = build(:user, password: 'password', password_confirmation: 'password')
        expect(user).to be_valid
      end
    end
  end

  describe 'validations - role' do
    context 'when role is blank' do
      it 'is invalid' do
        user = build(:user, role: nil)
        expect(user).not_to be_valid
        expect(user.errors[:role]).to be_present
        expect(user.errors[:role].first).to match(/入力してください/)
      end
    end

    # Note: enumでは無効な値を直接設定できないため、このテストは省略
    # enumのバリデーションはRailsが自動的に行う

    context 'when role is valid' do
      it 'is valid for admin role' do
        user = build(:user, :admin)
        expect(user).to be_valid
        expect(user.role).to eq('admin')
      end

      it 'is valid for normal role' do
        user = build(:user, role: :normal)
        expect(user).to be_valid
        expect(user.role).to eq('normal')
      end
    end
  end

  describe 'dependent: :destroy' do
    let(:user) { create(:user) }

    context 'when message_threads exist' do
      before do
        create(:message_thread, creator_id: user.id)
        create(:message_thread, creator_id: user.id)
      end

      it 'destroys associated message_threads when user is destroyed' do
        expect {
          user.destroy
        }.to change { MessageThread.count }.by(-2)
      end
    end

    context 'when messages exist' do
      let(:gpt_model) { create(:gpt_model, creator_id: user.id) }
      let(:message_thread) { create(:message_thread, creator_id: user.id) }

      before do
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id)
        create(:message, message_thread: message_thread, gpt_model: gpt_model, creator_id: user.id)
      end

      it 'destroys associated messages when user is destroyed' do
        expect {
          user.destroy
        }.to change { Message.count }.by(-2)
      end
    end

    context 'when gpt_models exist' do
      before do
        create(:gpt_model, creator_id: user.id)
        create(:gpt_model, creator_id: user.id)
      end

      it 'destroys associated gpt_models when user is destroyed' do
        expect {
          user.destroy
        }.to change { GptModel.count }.by(-2)
      end
    end
  end

  describe 'devise modules' do
    it 'includes database_authenticatable module' do
      expect(described_class.devise_modules).to include(:database_authenticatable)
    end

    it 'includes rememberable module' do
      expect(described_class.devise_modules).to include(:rememberable)
    end

    it 'includes trackable module' do
      expect(described_class.devise_modules).to include(:trackable)
    end

    it 'includes lockable module' do
      expect(described_class.devise_modules).to include(:lockable)
    end
  end
end

