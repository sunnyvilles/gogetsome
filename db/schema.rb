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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120614182715) do

  create_table "media", :force => true do |t|
    t.integer  "user_id",                      :default => 0,   :null => false
    t.string   "media_type",      :limit => 0, :default => "1", :null => false
    t.string   "service_id",      :limit => 0, :default => "1", :null => false
    t.string   "media_url"
    t.string   "thumb_image_url"
    t.integer  "theme_id"
    t.integer  "view_count",                   :default => 0,   :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "media", ["user_id"], :name => "primary_index"

  create_table "requested_invites", :force => true do |t|
    t.string   "email",                :limit => 80,  :null => false
    t.string   "ip_address",                          :null => false
    t.string   "city",                 :limit => 150
    t.string   "state",                :limit => 150
    t.string   "country",              :limit => 50
    t.string   "zipcode",              :limit => 30
    t.datetime "signedup_at"
    t.integer  "total_reminders_sent"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "requested_invites", ["email"], :name => "index_requested_invites_on_email", :unique => true

  create_table "user_details", :force => true do |t|
    t.integer  "user_id",                   :null => false
    t.string   "remote_ip",  :limit => 25,  :null => false
    t.string   "city",       :limit => 200
    t.string   "region",     :limit => 200
    t.string   "country",    :limit => 200
    t.string   "zipcode",    :limit => 20
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "user_details", ["user_id"], :name => "UNIQUE", :unique => true

  create_table "user_service_details", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
