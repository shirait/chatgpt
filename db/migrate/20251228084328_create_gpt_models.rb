class CreateGptModels < ActiveRecord::Migration[8.1]
  def change
    create_table :gpt_models do |t|
      t.string  :name,        null: false
      t.string  :description, null: true
      t.integer :creator_id,  null: false

      t.timestamps
    end
    add_index :gpt_models, [:name]
    add_index :gpt_models, [:creator_id]
  end
end
