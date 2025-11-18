class AddEmbeddingToRecipes < ActiveRecord::Migration[8.0]
  def change
    enable_extension "vector"
    
    add_column :recipes, :embedding, :text
  end
end
