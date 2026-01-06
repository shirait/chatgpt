puts "GPTモデルデータを作成中..."

creator_id = User.admin.pluck(:id).first

GptModel.create!(
  name: 'gpt-4.1-mini',
  description: 'GPT-4.1-miniはGPT-4の改良版です。GPT-4.1より値段が安いです。',
  creator_id: creator_id,
  updater_id: creator_id
)

GptModel.create!(
  name: 'gpt-5-mini',
  description: '詳細に定義されたタスク用。高速で安価な GPT-5 バージョン',
  creator_id: creator_id,
  updater_id: creator_id
)

GptModel.create!(
  name: 'gpt-5.2',
  description: 'さまざまな業界にまたがるコーディングやエージェント型タスクに最適なモデルです。',
  creator_id: creator_id,
  updater_id: creator_id,
  active: true
)
