class AddActiveToGptModels < ActiveRecord::Migration[8.1]
  def change
    add_column :gpt_models, :active, :boolean, default: false, null: false
  end
end
