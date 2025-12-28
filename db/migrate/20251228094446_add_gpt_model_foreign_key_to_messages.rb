class AddGptModelForeignKeyToMessages < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :messages, :gpt_models, on_delete: :restrict
  end
end
