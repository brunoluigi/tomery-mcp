class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :ip_address
      t.string :user_agent
      t.string :mcp_token, null: false

      t.timestamps
    end

    add_index :sessions, :mcp_token, unique: true
  end
end
