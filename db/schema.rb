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

ActiveRecord::Schema.define(version: 20170626232006) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "iois", force: :cascade do |t|
    t.integer "principal_id"
    t.string "stock"
    t.string "side"
    t.text "ranked_eps", default: [], array: true
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "negotiation_principals", force: :cascade do |t|
    t.integer "negotiation_id"
    t.integer "principal_id"
    t.integer "satisfaction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "negotiations", force: :cascade do |t|
    t.integer "agent_id"
    t.boolean "active"
    t.boolean "traded"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "principals", force: :cascade do |t|
    t.string "name"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sponserships", force: :cascade do |t|
    t.integer "principal_id"
    t.integer "agent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
