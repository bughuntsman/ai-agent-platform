class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: 'member'

      t.timestamps
    end

    add_index :users, [:email, :tenant_id], unique: true
  end
end
