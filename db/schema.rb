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

ActiveRecord::Schema.define(version: 20161221083655) do

  create_table "statuses", force: :cascade do |t|
    t.string   "ids",             limit: 255
    t.string   "text",            limit: 255
    t.string   "created_at_time", limit: 255
    t.string   "pic_ids",         limit: 255
    t.string   "user_ids",        limit: 255
    t.integer  "repost_count",    limit: 4
    t.integer  "comments_count",  limit: 4
    t.integer  "attitudes_count", limit: 4
    t.boolean  "pic_mul"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "ids",               limit: 255
    t.string   "screen_name",       limit: 255
    t.string   "name",              limit: 255
    t.string   "location",          limit: 255
    t.integer  "city",              limit: 4
    t.integer  "province",          limit: 4
    t.string   "description",       limit: 255
    t.string   "profile_image_url", limit: 255
    t.integer  "followers_count",   limit: 4
    t.integer  "friends_count",     limit: 4
    t.integer  "statuses_count",    limit: 4
    t.boolean  "sex"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

end
