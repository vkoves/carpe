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

ActiveRecord::Schema.define(version: 2018_11_24_064632) do

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "privacy"
    t.integer "group_id"
    t.index ["group_id"], name: "index_categories_on_group_id"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "categories_repeat_exceptions", id: false, force: :cascade do |t|
    t.integer "repeat_exception_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_categories_repeat_exceptions_on_category_id"
    t.index ["repeat_exception_id"], name: "index_categories_repeat_exceptions_on_repeat_exception_id"
  end

  create_table "event_invites", force: :cascade do |t|
    t.integer "role", default: 0, null: false
    t.integer "status", default: 3, null: false
    t.integer "sender_id", null: false
    t.integer "user_id", null: false
    t.integer "host_event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.integer "hosted_event_id"
    t.index ["host_event_id", "user_id"], name: "index_event_invites_on_host_event_id_and_user_id", unique: true
    t.index ["host_event_id"], name: "index_event_invites_on_host_event_id"
    t.index ["hosted_event_id"], name: "index_event_invites_on_hosted_event_id"
    t.index ["sender_id"], name: "index_event_invites_on_sender_id"
    t.index ["token"], name: "index_event_invites_on_token", unique: true
    t.index ["user_id"], name: "index_event_invites_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "category_id"
    t.datetime "end_date"
    t.string "repeat"
    t.string "location"
    t.date "repeat_start"
    t.date "repeat_end"
    t.integer "group_id"
    t.integer "privacy", default: 1, null: false
    t.integer "base_event_id"
    t.boolean "guests_can_invite", default: false, null: false
    t.boolean "guest_list_hidden", default: false, null: false
    t.index ["base_event_id"], name: "index_events_on_base_event_id"
    t.index ["category_id"], name: "index_events_on_category_id"
    t.index ["group_id"], name: "index_events_on_group_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "events_repeat_exceptions", id: false, force: :cascade do |t|
    t.integer "repeat_exception_id"
    t.integer "event_id"
    t.index ["event_id"], name: "index_events_repeat_exceptions_on_event_id"
    t.index ["repeat_exception_id"], name: "index_events_repeat_exceptions_on_repeat_exception_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banner_image_url"
    t.boolean "posts_preapproved"
    t.integer "privacy", default: 0
    t.string "custom_url"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "banner_file_name"
    t.string "banner_content_type"
    t.bigint "banner_file_size"
    t.datetime "banner_updated_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "receiver_id", null: false
    t.integer "sender_id"
    t.string "message"
    t.boolean "viewed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "entity_id"
    t.string "entity_type"
    t.integer "event", default: 0, null: false
    t.index ["entity_id", "entity_type"], name: "index_notifications_on_entity_id_and_entity_type"
    t.index ["event", "receiver_id", "sender_id", "entity_id", "message"], name: "index_unique_notifications", unique: true
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.boolean "confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repeat_exceptions", force: :cascade do |t|
    t.string "name"
    t.date "start"
    t.date "end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "group_id"
    t.index ["group_id"], name: "index_repeat_exceptions_on_group_id"
    t.index ["user_id"], name: "index_repeat_exceptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "image_url"
    t.boolean "admin"
    t.boolean "public_profile", default: false
    t.string "home_time_zone", default: "Central Time (US & Canada)"
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.integer "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string "banner_file_name"
    t.string "banner_content_type"
    t.integer "banner_file_size"
    t.datetime "banner_updated_at"
    t.string "custom_url", default: ""
    t.integer "default_event_invite_category_id"
    t.index ["default_event_invite_category_id"], name: "index_users_on_default_event_invite_category_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "role", default: 0
    t.boolean "accepted", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_users_groups_on_group_id"
    t.index ["user_id", "group_id"], name: "index_users_groups_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_users_groups_on_user_id"
  end

end
