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

ActiveRecord::Schema.define(version: 20140715173240) do

  create_table "ofac_sdn_individuals", force: true do |t|
    t.string   "last_name",              limit: 50
    t.string   "first_name_1",           limit: 25
    t.string   "first_name_2",           limit: 25
    t.string   "first_name_3",           limit: 25
    t.string   "first_name_4",           limit: 25
    t.string   "first_name_5",           limit: 25
    t.string   "first_name_6",           limit: 25
    t.string   "first_name_7",           limit: 25
    t.string   "first_name_8",           limit: 25
    t.string   "alternate_last_name",    limit: 50
    t.string   "alternate_first_name_1", limit: 25
    t.string   "alternate_first_name_2", limit: 25
    t.string   "alternate_first_name_3", limit: 25
    t.string   "alternate_first_name_4", limit: 25
    t.string   "alternate_first_name_5", limit: 25
    t.string   "alternate_first_name_6", limit: 25
    t.string   "alternate_first_name_7", limit: 25
    t.string   "alternate_first_name_8", limit: 25
    t.string   "address"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ofac_sdn_individuals", ["last_name", "first_name_1", "first_name_2", "first_name_3", "first_name_4", "first_name_5", "first_name_6", "first_name_7", "first_name_8", "alternate_last_name", "alternate_first_name_1", "alternate_first_name_2", "alternate_first_name_3", "alternate_first_name_4", "alternate_first_name_5", "alternate_first_name_6", "alternate_first_name_7", "alternate_first_name_8"], name: "ofac_sdn_individuals_names"

end
