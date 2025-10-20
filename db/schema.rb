# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_01_01_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_channels", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.string "channel_type", null: false
    t.jsonb "configuration", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "channel_type"], name: "index_agent_channels_on_agent_id_and_channel_type", unique: true
    t.index ["agent_id"], name: "index_agent_channels_on_agent_id"
  end

  create_table "agents", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "llm_provider", null: false
    t.string "llm_model", null: false
    t.text "system_prompt", null: false
    t.float "temperature", default: 0.7
    t.integer "max_tokens", default: 1000
    t.jsonb "configuration", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_agents_on_active"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.string "channel_type", null: false
    t.string "channel_user_id", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_conversations_on_agent_id"
    t.index ["channel_type", "channel_user_id"], name: "index_conversations_on_channel_type_and_channel_user_id"
    t.index ["status"], name: "index_conversations_on_status"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "role", null: false
    t.text "content", null: false
    t.integer "tokens_used", default: 0
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["role"], name: "index_messages_on_role"
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.jsonb "settings", default: {}, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.bigint "tenant_id", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email", "tenant_id"], name: "index_users_on_email_and_tenant_id", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  add_foreign_key "agent_channels", "agents"
  add_foreign_key "conversations", "agents"
  add_foreign_key "messages", "conversations"
  add_foreign_key "users", "tenants"
end
