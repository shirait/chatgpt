class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :message_thread, null: false, foreign_key: { on_delete: :cascade } # 親スレッドが削除されたら子スレッドも削除
      t.integer :message_type, null: false
      t.text :content, null: false
      t.string :creator_id, null: false
      t.string :updater_id, null: false

      t.timestamps
    end
    add_index :messages, [:creator_id, :created_at]
    add_index :messages, [:updater_id, :updated_at]
  end
end
