require 'rails_helper'

RSpec.describe GptModel, type: :model do
  describe 'associations' do
    it { should belong_to(:user).with_foreign_key(:creator_id) }
    it { should have_many(:messages).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_length_of(:description).is_at_most(255) }
    it { should validate_presence_of(:creator_id) }
  end

  describe '.active_gpt_model' do
    let!(:user) { create(:user) }
    let!(:active_model) { create(:gpt_model, :active, creator_id: user.id) }
    let!(:inactive_model) { create(:gpt_model, active: false, creator_id: user.id) }

    it 'returns the active GPT model' do
      expect(described_class.active_gpt_model).to eq(active_model)
    end

    context 'when there are multiple active models' do
      let!(:another_active_model) { create(:gpt_model, :active, creator_id: user.id) }

      it 'returns the first active model' do
        expect(described_class.active_gpt_model).to eq(active_model)
      end
    end

    context 'when there are no active models' do
      before do
        active_model.update(active: false)
      end

      it 'returns nil' do
        expect(described_class.active_gpt_model).to be_nil
      end
    end
  end

  describe '.build_gpt_model' do
    let(:user) { create(:user) }
    let(:params) do
      {
        name: 'GPT-3.5',
        description: 'OpenAI GPT-3.5 model',
        active: true
      }
    end

    it 'creates a new GptModel instance with the given params' do
      gpt_model = described_class.build_gpt_model(params, creator_id: user.id)

      expect(gpt_model).to be_a(GptModel)
      expect(gpt_model).to be_new_record
      expect(gpt_model.name).to eq('GPT-3.5')
      expect(gpt_model.description).to eq('OpenAI GPT-3.5 model')
      expect(gpt_model.active).to be true
      expect(gpt_model.creator_id).to eq(user.id)
    end

    it 'sets the creator_id correctly' do
      gpt_model = described_class.build_gpt_model(params, creator_id: user.id)

      expect(gpt_model.creator_id).to eq(user.id)
    end
  end

  describe 'validations - name' do
    let(:user) { create(:user) }

    context 'when name is blank' do
      it 'is invalid' do
        gpt_model = build(:gpt_model, name: '', creator_id: user.id)
        expect(gpt_model).not_to be_valid
        expect(gpt_model.errors[:name]).to include("can't be blank")
      end
    end

    context 'when name is too long' do
      it 'is invalid' do
        long_name = 'a' * 256
        gpt_model = build(:gpt_model, name: long_name, creator_id: user.id)
        expect(gpt_model).not_to be_valid
        expect(gpt_model.errors[:name]).to include('is too long (maximum is 255 characters)')
      end
    end

    context 'when name is valid' do
      it 'is valid' do
        gpt_model = build(:gpt_model, name: 'Valid Name', creator_id: user.id)
        expect(gpt_model).to be_valid
      end
    end
  end

  describe 'validations - description' do
    let(:user) { create(:user) }

    context 'when description is too long' do
      it 'is invalid' do
        long_description = 'a' * 256
        gpt_model = build(:gpt_model, description: long_description, creator_id: user.id)
        expect(gpt_model).not_to be_valid
        expect(gpt_model.errors[:description]).to include('is too long (maximum is 255 characters)')
      end
    end

    context 'when description is valid' do
      it 'is valid' do
        gpt_model = build(:gpt_model, description: 'Valid description', creator_id: user.id)
        expect(gpt_model).to be_valid
      end
    end

    context 'when description is nil' do
      it 'is valid' do
        gpt_model = build(:gpt_model, description: nil, creator_id: user.id)
        expect(gpt_model).to be_valid
      end
    end
  end

  describe 'validations - creator_id' do
    context 'when creator_id is blank' do
      it 'is invalid' do
        gpt_model = build(:gpt_model, creator_id: nil)
        expect(gpt_model).not_to be_valid
        expect(gpt_model.errors[:creator_id]).to include("can't be blank")
      end
    end
  end

  describe 'dependent: :restrict_with_error' do
    let(:user) { create(:user) }
    let(:gpt_model) { create(:gpt_model, creator_id: user.id) }

    context 'when messages exist' do
      before do
        message_thread = create(:message_thread, creator_id: user.id)
        create(:message, gpt_model: gpt_model, message_thread: message_thread, creator_id: user.id)
      end

      it 'prevents deletion' do
        expect { gpt_model.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
      end
    end

    context 'when no messages exist' do
      it 'allows deletion' do
        expect { gpt_model.destroy }.to change { described_class.count }.by(-1)
      end
    end
  end
end

