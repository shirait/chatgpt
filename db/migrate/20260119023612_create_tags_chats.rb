class CreateTagsChats < ActiveRecord::Migration[8.1]
  def change
    create_table :tags_chats do |t|
      t.bigint :tag_id,            null: false
      t.bigint :message_thread_id, null: false
    end
    add_index :tags_chats, [ :tag_id, :message_thread_id ], unique: true
    add_index :tags_chats, [ :message_thread_id ]
  end
end
