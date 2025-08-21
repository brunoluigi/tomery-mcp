class CreateRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :recipes, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :title
      t.string :description
      t.jsonb :ingredients
      t.jsonb :instructions

      t.timestamps
    end
  end
end
