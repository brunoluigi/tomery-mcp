class EnablePgvectorExtension < ActiveRecord::Migration[8.0]
  def up
    enable_extension "vector"

    # Change embedding column from text to vector type
    # First, remove any existing JSON-encoded embeddings (they'll be regenerated)
    execute "UPDATE recipes SET embedding = NULL WHERE embedding IS NOT NULL"

    # Change column type to vector using raw SQL
    # Rails doesn't natively support vector type, so we use execute
    remove_column :recipes, :embedding
    execute "ALTER TABLE recipes ADD COLUMN embedding vector(1536)"
  end

  def down
    # Convert back to text
    remove_column :recipes, :embedding
    add_column :recipes, :embedding, :text
    disable_extension "vector"
  end
end
