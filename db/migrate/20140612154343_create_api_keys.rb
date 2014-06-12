class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :access_token , null: false, index: true
      t.references :user, null: false, index: true
      t.boolean :active, null: false, default: true
      t.datetime :expires_at
      t.timestamps
    end
  end
end
