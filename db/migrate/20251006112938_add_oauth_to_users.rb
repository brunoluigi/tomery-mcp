class AddOauthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :name, :string
    add_column :users, :image_url, :string

    # Make password_digest nullable since OAuth users won't have passwords
    change_column_null :users, :password_digest, true

    # Add index for OAuth lookups
    add_index :users, [ :provider, :uid ], unique: true
  end
end
