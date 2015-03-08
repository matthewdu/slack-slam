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

ActiveRecord::Schema.define(version: 20150308050738) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "commands", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "commands", ["user_id", "key"], name: "index_commands_on_user_id_and_key", unique: true, using: :btree
  add_index "commands", ["user_id"], name: "index_commands_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "slack_team_id"
    t.string   "slack_team_name"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "teams", ["slack_team_id"], name: "index_teams_on_slack_team_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "slack_name"
    t.string   "slack_user_id"
    t.integer  "team_id"
    t.string   "access_token"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "users", ["slack_user_id"], name: "index_users_on_slack_user_id", using: :btree
  add_index "users", ["team_id"], name: "index_users_on_team_id", using: :btree

end
