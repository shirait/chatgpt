class CreateGptModels < ActiveRecord::Migration[8.1]
  def change
    create_table :gpt_models do |t|
      t.timestamps
    end
  end
end
