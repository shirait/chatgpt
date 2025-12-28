class CreateMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :messages do |t|
      t.references :message_thread, null: false, foreign_key: { on_delete: :cascade }
      t.references :gpt_model,      null: false, foreign_key: { on_delete: :restrict }
      t.integer    :message_type,   null: false
      t.text       :content,        null: false
      t.integer    :creator_id,     null: false

      t.timestamps
    end
    add_index :messages, [:creator_id]
  end
end
