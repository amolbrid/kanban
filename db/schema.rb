# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140808155803) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: true do |t|
    t.string   "name",                       null: false
    t.string   "milestone"
    t.boolean  "is_public",  default: false, null: false
    t.date     "due_date"
    t.string   "slug"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "boards", ["name", "user_id"], name: "index_boards_on_name_and_user_id", unique: true, using: :btree
  add_index "boards", ["slug"], name: "index_boards_on_slug", unique: true, using: :btree

  create_table "repositories", force: true do |t|
    t.string   "url",            null: false
    t.string   "milestone_name"
    t.string   "milestone_id"
    t.integer  "board_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stages", force: true do |t|
    t.string   "name",          null: false
    t.string   "github_label",  null: false
    t.integer  "ui_sort_order"
    t.integer  "board_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string "provider",  null: false
    t.string "uid",       null: false
    t.string "name",      null: false
    t.string "nickname"
    t.string "email"
    t.string "image_url"
    t.string "token"
  end

end
