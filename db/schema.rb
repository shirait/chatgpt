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

ActiveRecord::Schema[8.1].define(version: 2026_01_24_215950) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "delayed_jobs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at"
    t.datetime "failed_at"
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "locked_at"
    t.string "locked_by"
    t.integer "priority", default: 0, null: false
    t.string "queue"
    t.datetime "run_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "gpt_models", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.string "description"
    t.integer "max_prev_message_count", default: 5, null: false
    t.string "name", null: false
    t.float "temperature", default: 0.7, null: false
    t.datetime "updated_at", null: false
    t.integer "updater_id", null: false
    t.index ["creator_id"], name: "index_gpt_models_on_creator_id"
    t.index ["name"], name: "index_gpt_models_on_name"
    t.index ["updater_id"], name: "index_gpt_models_on_updater_id"
  end

  create_table "login_logs", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address", null: false
    t.string "login_identifier", null: false
    t.integer "login_type", default: 0, null: false
    t.string "referer"
    t.integer "result", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "user_agent", null: false
    t.bigint "user_id"
    t.index ["created_at"], name: "index_login_logs_on_created_at"
    t.index ["login_type"], name: "index_login_logs_on_login_type"
    t.index ["result"], name: "index_login_logs_on_result"
    t.index ["user_id"], name: "index_login_logs_on_user_id"
  end

  create_table "message_threads", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_message_threads_on_creator_id"
    t.index ["title"], name: "index_message_threads_on_title"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.bigint "gpt_model_id", null: false
    t.bigint "message_thread_id", null: false
    t.integer "message_type", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_messages_on_creator_id"
    t.index ["gpt_model_id"], name: "fk_rails_73e5df9141"
    t.index ["message_thread_id"], name: "fk_rails_48a2f10058"
  end

  create_table "tag_message_threads", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "message_thread_id", null: false
    t.bigint "tag_id", null: false
    t.index ["message_thread_id"], name: "index_tag_message_threads_on_message_thread_id"
    t.index ["tag_id"], name: "index_tag_message_threads_on_tag_id"
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id", "name"], name: "index_tags_on_creator_id_and_name"
    t.index ["creator_id"], name: "index_tags_on_creator_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.integer "role", default: 1, null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.integer "updater_id", null: false
    t.index ["creator_id"], name: "index_users_on_creator_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["name"], name: "index_users_on_name"
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["updater_id"], name: "index_users_on_updater_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "login_logs", "users"
  add_foreign_key "messages", "gpt_models"
  add_foreign_key "messages", "message_threads", on_delete: :cascade
  add_foreign_key "tag_message_threads", "message_threads"
  add_foreign_key "tag_message_threads", "tags"
  add_foreign_key "tags", "users", column: "creator_id"
end
