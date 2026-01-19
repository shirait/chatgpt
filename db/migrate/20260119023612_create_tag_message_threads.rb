class CreateTagMessageThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :tag_message_threads do |t|
      t.references :tag,            null: false, foreign_key: true, type: :bigint
      t.references :message_thread, null: false, foreign_key: true, type: :bigint
    end
  end
end
