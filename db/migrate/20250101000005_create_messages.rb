class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string :role, null: false
      t.text :content, null: false
      t.integer :tokens_used, default: 0
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :messages, :role
  end
end
