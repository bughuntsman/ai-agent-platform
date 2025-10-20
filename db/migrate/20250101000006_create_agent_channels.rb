class CreateAgentChannels < ActiveRecord::Migration[7.1]
  def change
    create_table :agent_channels do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :channel_type, null: false
      t.jsonb :configuration, null: false, default: {}
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :agent_channels, [:agent_id, :channel_type], unique: true
  end
end
