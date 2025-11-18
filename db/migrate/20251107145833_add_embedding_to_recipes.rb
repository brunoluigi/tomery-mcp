class AddEmbeddingToRecipes < ActiveRecord::Migration[8.0]
  def change
    add_column :recipes, :embedding, :text
  end
end
