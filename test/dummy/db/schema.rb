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

ActiveRecord::Schema.define(version: 0) do
  create_table :ofac_sdns do |t|
    t.text :name
    t.string :sdn_type
    t.string :program
    t.string :title
    t.string :vessel_call_sign
    t.string :vessel_type
    t.string :vessel_tonnage
    t.string :gross_registered_tonnage
    t.string :vessel_flag
    t.string :vessel_owner
    t.text :remarks
    t.text :address
    t.string :city
    t.string :country
    t.string :address_remarks
    t.string :alternate_identity_type
    t.text :alternate_identity_name
    t.string :alternate_identity_remarks
    t.timestamps
  end
  add_index :ofac_sdns, :sdn_type

end
