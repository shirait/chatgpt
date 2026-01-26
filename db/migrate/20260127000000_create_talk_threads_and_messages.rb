class CreateTalkThreadsAndMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :talk_threads do |t|
      t.references :user, null: false, foreign_key: true#, unique: true
      t.timestamps
    end

    # add_index :talk_threads, :user_id, unique: true

    create_table :talk_messages do |t|
      t.references :talk_thread, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.text :content, null: false
      t.timestamps
    end
  end
end
