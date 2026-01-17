class AddActiveToMessageThreads < ActiveRecord::Migration[8.1]
  def change
    add_column :message_threads, :active, :boolean, default: true, null: false
  end
end
