class AddTemperatureToGptModels < ActiveRecord::Migration[8.1]
  def change
    add_column(:gpt_models, :temperature, :float, default: 0.7, null: false)
    add_column(:gpt_models, :max_prev_message_count, :integer, default: 5, null: false)
  end
end
