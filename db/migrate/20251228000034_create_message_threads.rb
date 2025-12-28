class CreateMessageThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :message_threads do |t|
      t.string   :title,      null: false
      t.string   :creator_id, null: false
      t.string   :updater_id, null: false

      t.timestamps
    end

    add_index :message_threads, [:title]
    add_index :message_threads, [:creator_id, :created_at]
    add_index :message_threads, [:updater_id, :updated_at]
  end
end
