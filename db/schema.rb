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

ActiveRecord::Schema.define(version: 20150903230817) do

  create_table "app_status", force: :cascade do |t|
    t.datetime "started"
    t.datetime "finished"
    t.boolean  "scraping"
    t.integer  "player_count"
    t.integer  "current_player"
  end

  create_table "players", force: :cascade do |t|
    t.string "code",     limit: 255
    t.string "name",     limit: 255
    t.string "team",     limit: 255
    t.string "value",    limit: 255
    t.string "position", limit: 255
    t.string "total",    limit: 255
    t.index ["code"], name: "index_players_on_code", unique: true
  end

  create_table "scores", force: :cascade do |t|
    t.string "code",   limit: 255
    t.string "scores", limit: 255
    t.index ["code"], name: "index_scores_on_code", unique: true
  end

end
