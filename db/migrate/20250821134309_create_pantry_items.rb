class CreatePantryItems < ActiveRecord::Migration[8.0]
  def change
    create_table :pantry_items, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :quantity

      t.timestamps
    end
  end
end
