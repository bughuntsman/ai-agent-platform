class CreateTenants < ActiveRecord::Migration[7.1]
  def change
    create_table :tenants do |t|
      t.string :name, null: false
      t.string :subdomain, null: false
      t.jsonb :settings, null: false, default: {}
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :tenants, :subdomain, unique: true
  end
end
