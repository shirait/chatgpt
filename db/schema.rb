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

ActiveRecord::Schema[8.1].define(version: 2025_12_28_000044) do
  create_table "message_threads", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "creator_id", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "updater_id", null: false
    t.index ["creator_id", "created_at"], name: "index_message_threads_on_creator_id_and_created_at"
    t.index ["title"], name: "index_message_threads_on_title"
    t.index ["updater_id", "updated_at"], name: "index_message_threads_on_updater_id_and_updated_at"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "creator_id", null: false
    t.bigint "message_thread_id", null: false
    t.integer "message_type", null: false
    t.datetime "updated_at", null: false
    t.string "updater_id", null: false
    t.index ["creator_id", "created_at"], name: "index_messages_on_creator_id_and_created_at"
    t.index ["message_thread_id"], name: "index_messages_on_message_thread_id"
    t.index ["updater_id", "updated_at"], name: "index_messages_on_updater_id_and_updated_at"
  end

  add_foreign_key "messages", "message_threads", on_delete: :cascade
end
