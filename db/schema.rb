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

  create_table "buckets", force: :cascade do |t| 
    t.integer  "experiment_id",    limit: 4,                     null: false
    t.string   "http_verb",        limit: 8,                     null: false
    t.text     "api_path",         limit: 65535,                 null: false
    t.string   "uuid_key",         limit: 128
    t.string   "uuid_placeholder", limit: 64
    t.text     "request_body",     limit: 65535,                 null: false
    t.integer  "timeout",          limit: 4,     default: 1000,  null: false
    t.string   "impression_id",    limit: 64,                    null: false
    t.integer  "is_graph_query",   limit: 1,     default: 1,     null: false
    t.integer  "is_empty",         limit: 1,     default: 0,     null: false
    t.string   "modular",          limit: 64,                    null: false
    t.string   "description",      limit: 100
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "created_by",       limit: 30
    t.string   "updated_by",       limit: 30
    t.text     "variables",        limit: 65535
    t.string   "prev_modular",     limit: 64,    default: "0~0"
    t.integer  "is_emergency",     limit: 1,     default: 0
    t.string   "snapshot_modular", limit: 64,    default: "0~0"
  end

  add_index "buckets", ["experiment_id"], name: "idx_experiment_id", using: :btree
  add_index "buckets", ["impression_id"], name: "idx_impression_id", using: :btree
  add_index "buckets", ["impression_id"], name: "ux_impression_id", unique: true, using: :btree

  create_table "experiments", force: :cascade do |t|
    t.integer  "service_id",      limit: 4,                 null: false
    t.string   "service_name",    limit: 128,               null: false
    t.string   "name",            limit: 64,                null: false
    t.string   "description",     limit: 255,               null: false
    t.string   "experiment_type", limit: 8,   default: "u", null: false
    t.integer  "total_modular",   limit: 4,   default: 100, null: false
    t.string   "created_by",      limit: 30
    t.string   "updated_by",      limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "is_emergency",    limit: 1,   default: 0
  end

  add_index "experiments", ["service_id", "name"], name: "ux_service_id_name", unique: true, using: :btree
end
