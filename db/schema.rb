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

ActiveRecord::Schema[8.1].define(version: 2025_12_28_084328) do
  create_table "gpt_models", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "creator_id", null: false
    t.string "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_gpt_models_on_creator_id"
    t.index ["name"], name: "index_gpt_models_on_name"
  end

  create_table "message_threads", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
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
    t.index ["message_thread_id"], name: "fk_rails_48a2f10058"
  end

  add_foreign_key "messages", "message_threads", on_delete: :cascade
end
