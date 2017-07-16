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

ActiveRecord::Schema.define(version: 20170716060459) do

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.string   "privacy"
    t.integer  "group_id"
  end

  add_index "categories", ["group_id"], name: "index_categories_on_group_id"
  add_index "categories", ["user_id"], name: "index_categories_on_user_id"

  create_table "categories_repeat_exceptions", id: false, force: :cascade do |t|
    t.integer "repeat_exception_id"
    t.integer "category_id"
  end

  add_index "categories_repeat_exceptions", ["category_id"], name: "index_categories_repeat_exceptions_on_category_id"
  add_index "categories_repeat_exceptions", ["repeat_exception_id"], name: "index_categories_repeat_exceptions_on_repeat_exception_id"

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "date"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "end_date"
    t.string   "repeat"
    t.string   "location"
    t.date     "repeat_start"
    t.date     "repeat_end"
    t.integer  "group_id"
  end

  add_index "events", ["category_id"], name: "index_events_on_category_id"
  add_index "events", ["group_id"], name: "index_events_on_group_id"
  add_index "events", ["user_id"], name: "index_events_on_user_id"

  create_table "events_repeat_exceptions", id: false, force: :cascade do |t|
    t.integer "repeat_exception_id"
    t.integer "event_id"
  end

  add_index "events_repeat_exceptions", ["event_id"], name: "index_events_repeat_exceptions_on_event_id"
  add_index "events_repeat_exceptions", ["repeat_exception_id"], name: "index_events_repeat_exceptions_on_repeat_exception_id"

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "image_url"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "banner_image_url"
    t.boolean  "posts_preapproved"
    t.integer  "privacy",             default: 0
    t.string   "custom_url"
    t.string   "banner_file_name"
    t.string   "banner_content_type"
    t.integer  "banner_file_size"
    t.datetime "banner_updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "receiver_id"
    t.integer  "sender_id"
    t.string   "message"
    t.boolean  "viewed",      default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.boolean  "confirmed"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "repeat_exceptions", force: :cascade do |t|
    t.string   "name"
    t.date     "start"
    t.date     "end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "group_id"
  end

  add_index "repeat_exceptions", ["group_id"], name: "index_repeat_exceptions_on_group_id"
  add_index "repeat_exceptions", ["user_id"], name: "index_repeat_exceptions_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",                           null: false
    t.string   "encrypted_password",     default: "",                           null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "image_url"
    t.boolean  "admin"
    t.boolean  "public_profile",         default: false
    t.string   "home_time_zone",         default: "Central Time (US & Canada)"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "banner_file_name"
    t.string   "banner_content_type"
    t.integer  "banner_file_size"
    t.datetime "banner_updated_at"
    t.string   "custom_url",             default: ""
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "users_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "role",          default: 0
  end

  add_index "users_groups", ["group_id"], name: "index_users_groups_on_group_id"
  add_index "users_groups", ["user_id"], name: "index_users_groups_on_user_id"

end
