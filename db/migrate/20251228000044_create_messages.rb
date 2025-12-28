class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.bigint :message_thread_id, null: false
      t.bigint :gpt_model_id,       null: false
      t.integer :message_type,      null: false
      t.text    :content,           null: false
      t.integer :creator_id,        null: false

      t.timestamps
    end

    add_foreign_key :messages, :message_threads, on_delete: :cascade
    # gpt_modelsテーブルは後で作成されるため、外部キー制約は別のマイグレーションで追加
    add_index :messages, [ :creator_id ]
  end
end
