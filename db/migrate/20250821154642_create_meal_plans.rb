class CreateMealPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :meal_plans, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :recipe, null: false, foreign_key: true, type: :uuid
      t.date :date, null: false
      t.string :meal, null: false

      t.timestamps
    end

    add_index :meal_plans, :date
  end
end
