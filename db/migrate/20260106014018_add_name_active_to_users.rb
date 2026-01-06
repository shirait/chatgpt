class AddNameActiveToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :active, :boolean, default: true, null: false

    add_index :users, :name
  end
end
