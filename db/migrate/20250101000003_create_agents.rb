class CreateAgents < ActiveRecord::Migration[7.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.text :description
      t.string :llm_provider, null: false
      t.string :llm_model, null: false
      t.text :system_prompt, null: false
      t.float :temperature, default: 0.7
      t.integer :max_tokens, default: 1000
      t.jsonb :configuration, null: false, default: {}
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :agents, :active
  end
end
