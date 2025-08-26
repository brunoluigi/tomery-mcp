class AddNewFlagsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :active, :boolean, default: false, null: false
    add_column :users, :admin, :boolean, default: false, null: false
  end
end
