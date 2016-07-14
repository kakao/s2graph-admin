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

ActiveRecord::Schema.define() do

  create_table "authorities", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "service_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "authorities", ["service_id"], name: "index_authorities_on_service_id", using: :btree
  add_index "authorities", ["user_id"], name: "index_authorities_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",        limit: 255
    t.string   "authority",    limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "talk_user_id", limit: 4
    t.string   "s_header",     limit: 300
  end

  add_foreign_key "authorities", "services"
  add_foreign_key "authorities", "users"
end
