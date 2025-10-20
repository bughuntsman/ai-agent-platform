class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :channel_type, null: false
      t.string :channel_user_id, null: false
      t.jsonb :metadata, null: false, default: {}
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :conversations, [:channel_type, :channel_user_id]
    add_index :conversations, :status
  end
end
