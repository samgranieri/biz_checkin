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

ActiveRecord::Schema.define(version: 20140612154343) do

  create_table "api_keys", force: true do |t|
    t.string   "access_token",                null: false
    t.integer  "user_id",                     null: false
    t.boolean  "active",       default: true, null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["user_id"], name: "index_api_keys_on_user_id", using: :btree

  create_table "businesses", force: true do |t|
    t.string  "name"
    t.string  "address"
    t.string  "city"
    t.string  "zip"
    t.string  "state"
    t.string  "website"
    t.string  "phone"
    t.integer "waiting_period"
  end

  create_table "checkins", force: true do |t|
    t.integer  "user_id"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "checkins", ["business_id"], name: "index_checkins_on_business_id", using: :btree
  add_index "checkins", ["user_id"], name: "index_checkins_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
  end

end
