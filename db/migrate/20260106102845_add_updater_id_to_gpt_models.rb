class AddUpdaterIdToGptModels < ActiveRecord::Migration[8.1]
  def change
    add_column(:gpt_models, :updater_id, :integer, null: false)
    add_index(:gpt_models, :updater_id)
  end
end
