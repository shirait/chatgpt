require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:message_threads).dependent(:destroy).with_foreign_key(:creator_id) }
    it { should have_many(:messages).dependent(:destroy).with_foreign_key(:creator_id) }
    it { should have_many(:gpt_models).dependent(:restrict_with_error).with_foreign_key(:creator_id) }
    it { should have_many(:created_users).class_name("User").with_foreign_key(:creator_id).dependent(:restrict_with_error) }
    it { should have_many(:updated_users).class_name("User").with_foreign_key(:updater_id).dependent(:restrict_with_error) }
    it { should belong_to(:creator).class_name("User").with_foreign_key(:creator_id) }
    it { should belong_to(:updater).class_name("User").with_foreign_key(:updater_id) }
  end

  describe 'validations' do
    # 条件付きバリデーションや複雑なバリデーションは個別のテストで確認
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:creator_id) }
    it { should validate_presence_of(:updater_id) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values(admin: 0, normal: 1) }
  end

  describe 'validations - email' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }

    context 'when email is blank' do
      it 'is invalid' do
        user = build(:user, email: '', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
        expect(user.errors[:email].first).to match(/入力してください/)
      end
    end

    context 'when email is not unique' do
      let!(:existing_user) { create(:user, email: 'test@example.com', creator_user: admin_user, updater_user: admin_user) }

      it 'is invalid' do
        user = build(:user, email: 'test@example.com', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end
    end

    context 'when email is too long' do
      it 'is invalid' do
        long_email = 'a' * 250 + '@example.com'
        user = build(:user, email: long_email, creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
        expect(user.errors[:email].first).to match(/255文字以内/)
      end
    end

    context 'when email format is invalid' do
      it 'is invalid for email without @' do
        user = build(:user, email: 'invalidemail.com', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end

      it 'is invalid for email without domain' do
        user = build(:user, email: 'invalid@', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end

      it 'is invalid for email without local part' do
        user = build(:user, email: '@example.com', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end
    end

    context 'when email format is valid' do
      it 'is valid' do
        user = build(:user, email: 'valid@example.com', creator_user: admin_user, updater_user: admin_user)
        expect(user).to be_valid
      end
    end

    context 'when email is case insensitive unique' do
      let!(:existing_user) { create(:user, email: 'Test@Example.com', creator_user: admin_user, updater_user: admin_user) }

      it 'is invalid for same email with different case' do
        user = build(:user, email: 'test@example.com', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to be_present
      end
    end
  end

  describe 'validations - password' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }

    context 'when password is blank on create' do
      it 'is invalid' do
        user = build(:user, password: '', password_confirmation: '', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
        expect(user.errors[:password].first).to match(/入力してください/)
      end
    end

    context 'when password is blank on update' do
      let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }

      it 'is valid and does not update password' do
        original_encrypted_password = user.encrypted_password
        user.assign_update_attributes({ name: 'Updated Name', password: '', password_confirmation: '' }, updater_id: admin_user.id)
        expect(user).to be_valid
        user.save
        user.reload
        expect(user.name).to eq('Updated Name')
        expect(user.encrypted_password).to eq(original_encrypted_password)
      end
    end

    context 'when password is too short' do
      it 'is invalid' do
        user = build(:user, password: '12345', password_confirmation: '12345', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
        expect(user.errors[:password].first).to match(/6文字以上/)
      end
    end

    context 'when password is too long' do
      it 'is invalid' do
        long_password = 'a' * 129
        user = build(:user, password: long_password, password_confirmation: long_password, creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to be_present
        expect(user.errors[:password].first).to match(/128文字以内/)
      end
    end

    context 'when password is valid length' do
      it 'is valid for minimum length' do
        user = build(:user, password: '123456', password_confirmation: '123456', creator_user: admin_user, updater_user: admin_user)
        expect(user).to be_valid
      end

      it 'is valid for maximum length' do
        password = 'a' * 128
        user = build(:user, password: password, password_confirmation: password, creator_user: admin_user, updater_user: admin_user)
        expect(user).to be_valid
      end
    end
  end

  describe 'validations - password_confirmation' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }

    context 'when password_confirmation is blank on create' do
      it 'is invalid' do
        user = build(:user, password: 'password', password_confirmation: '', creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to be_present
        # confirmationバリデーションのエラーメッセージを確認
        expect(user.errors[:password_confirmation].first).to match(/一致しません|入力してください/)
      end
    end

    context 'when password_confirmation is blank on update with password' do
      let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }

      it 'is invalid' do
        user.assign_update_attributes({ password: 'newpassword', password_confirmation: '' }, updater_id: admin_user.id)
        expect(user).not_to be_valid
        expect(user.errors[:password_confirmation]).to be_present
      end
    end

    # Note: Deviseのデフォルトの動作では、password_confirmationの不一致は
    # passwordフィールドにエラーが追加されることがありますが、
    # このアプリケーションでは明示的なバリデーションがないため、このテストは省略

    context 'when password_confirmation matches password' do
      it 'is valid' do
        user = build(:user, password: 'password', password_confirmation: 'password', creator_user: admin_user, updater_user: admin_user)
        expect(user).to be_valid
      end
    end
  end

  describe 'validations - role' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }

    context 'when role is blank' do
      it 'is invalid' do
        user = build(:user, role: nil, creator_user: admin_user, updater_user: admin_user)
        expect(user).not_to be_valid
        expect(user.errors[:role]).to be_present
        expect(user.errors[:role].first).to match(/入力してください/)
      end
    end

    # Note: enumでは無効な値を直接設定できないため、このテストは省略
    # enumのバリデーションはRailsが自動的に行う

    context 'when role is valid' do
      it 'is valid for admin role' do
        user = build(:user, :admin, creator_user: admin_user, updater_user: admin_user)
        expect(user).to be_valid
        expect(user.role).to eq('admin')
      end

      it 'is valid for normal role' do
        user = build(:user, role: :normal, creator_user: admin_user, updater_user: admin_user)
        expect(user).to be_valid
        expect(user.role).to eq('normal')
      end
    end
  end

  describe 'dependent: :destroy' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }

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
      let(:gpt_model) { create(:gpt_model, creator_id: admin_user.id, updater_id: admin_user.id) }
      let(:message_thread) { create(:message_thread, creator_id: user.id) }

      before do
        create(:message, message_thread: message_thread, gpt_model: gpt_model, message_type: :user, creator_id: user.id)
        create(:message, message_thread: message_thread, gpt_model: gpt_model, message_type: :assistant, creator_id: user.id)
      end

      it 'destroys associated messages when user is destroyed' do
        expect {
          user.destroy!
        }.to change { Message.count }.by(-2)
      end
    end

    context 'when gpt_models exist' do
      before do
        create(:gpt_model, creator_id: user.id, updater_id: admin_user.id)
        create(:gpt_model, creator_id: user.id, updater_id: admin_user.id)
      end

      it 'raises error when trying to destroy user with associated gpt_models' do
        expect {
          user.destroy!
        }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(GptModel.count).to eq(2)
      end
    end
  end

  describe '.build_user' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }
    let(:creator) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:params) do
      {
        name: 'Test User',
        email: 'test@example.com',
        password: 'password',
        password_confirmation: 'password',
        role: :normal,
        active: true
      }
    end

    it 'creates a new User instance with the given params' do
      user = described_class.build_user(params, creator_id: creator.id)

      expect(user).to be_a(User)
      expect(user).to be_new_record
      expect(user.name).to eq('Test User')
      expect(user.email).to eq('test@example.com')
      expect(user.role).to eq('normal')
      expect(user.active).to be true
      expect(user.creator_id).to eq(creator.id)
      expect(user.updater_id).to eq(creator.id)
    end
  end

  describe '#assign_update_attributes' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }
    let(:user) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:updater) { create(:user, creator_user: admin_user, updater_user: admin_user) }
    let(:params) do
      {
        name: 'Updated Name',
        email: 'updated@example.com',
        role: :admin
      }
    end

    context 'when password is blank' do
      it 'removes password and password_confirmation attributes' do
        original_encrypted_password = user.encrypted_password
        user.assign_update_attributes({ **params, password: '', password_confirmation: '' }, updater_id: updater.id)

        expect(user.password).to be_nil
        expect(user.password_confirmation).to be_nil
        expect(user.name).to eq('Updated Name')
        expect(user.email).to eq('updated@example.com')
        expect(user.updater_id).to eq(updater.id)
      end

      it 'does not update password when saved' do
        original_encrypted_password = user.encrypted_password
        user.assign_update_attributes({ **params, password: '', password_confirmation: '' }, updater_id: updater.id)
        user.save
        user.reload

        expect(user.encrypted_password).to eq(original_encrypted_password)
      end
    end

    context 'when password is present' do
      it 'keeps password and password_confirmation attributes' do
        user.assign_update_attributes({ **params, password: 'newpassword', password_confirmation: 'newpassword' }, updater_id: updater.id)

        expect(user.password).to eq('newpassword')
        expect(user.password_confirmation).to eq('newpassword')
        expect(user.name).to eq('Updated Name')
        expect(user.updater_id).to eq(updater.id)
      end
    end

    it 'sets updater_id correctly' do
      user.assign_update_attributes(params, updater_id: updater.id)

      expect(user.updater_id).to eq(updater.id)
    end
  end

  describe 'validations - creator_id' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }

    context 'when creator_id is blank' do
      it 'is invalid' do
        user = User.new(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password',
          password_confirmation: 'password',
          role: :normal,
          active: true,
          creator_id: nil,
          updater_id: admin_user.id
        )
        expect(user).not_to be_valid
        expect(user.errors[:creator_id]).to be_present
        expect(user.errors[:creator_id].first).to match(/入力してください/)
      end
    end
  end

  describe 'validations - updater_id' do
    let!(:admin_user) { create(:user, :admin, :self_referential) }

    context 'when updater_id is blank' do
      it 'is invalid' do
        user = User.new(
          name: 'Test User',
          email: 'test@example.com',
          password: 'password',
          password_confirmation: 'password',
          role: :normal,
          active: true,
          creator_id: admin_user.id,
          updater_id: nil
        )
        expect(user).not_to be_valid
        expect(user.errors[:updater_id]).to be_present
        expect(user.errors[:updater_id].first).to match(/入力してください/)
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
