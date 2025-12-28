class CreateMessageThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :message_threads do |t|
      t.timestamps
    end
  end
end
