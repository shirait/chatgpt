class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.timestamps
    end

    add_index :tags, [ :creator_id, :name ]
  end
end
