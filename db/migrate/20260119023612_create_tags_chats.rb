class CreateTagsChats < ActiveRecord::Migration[8.1]
  def change
    create_table :tags_chats do |t|
      t.timestamps
    end
  end
end
