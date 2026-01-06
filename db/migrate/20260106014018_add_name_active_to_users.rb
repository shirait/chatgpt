class AddNameActiveToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :active, :boolean, default: true

    add_index :users, :name
  end
end
