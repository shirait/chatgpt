class AddCreatorIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column(:users, :creator_id, :integer, null: false)
    add_column(:users, :updater_id, :integer, null: false)
    add_index(:users, :creator_id)
    add_index(:users, :updater_id)
  end
end
