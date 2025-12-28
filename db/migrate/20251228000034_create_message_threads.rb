class CreateMessageThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :message_threads do |t|
      t.string  :title,      null: false
      t.integer :creator_id, null: false

      t.timestamps
    end

    add_index :message_threads, [ :title ]
    add_index :message_threads, [ :creator_id ]
  end
end
