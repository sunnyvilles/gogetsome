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

  create_table "requested_invites", :force => true do |t|
    t.string   "email",                :limit => 80,                 :null => false
    t.string   "ip_address",                                         :null => false
    t.string   "city",                 :limit => 150
    t.string   "state",                :limit => 150
    t.string   "country",              :limit => 50
    t.string   "zipcode",              :limit => 30
    t.datetime "signedup_at"
    t.integer  "total_reminders_sent",                :default => 0, :null => false
    t.string   "subscription_code",                                  :null => false
    t.string   "invite_code",                                        :null => false
    t.integer  "requested_invites",                   :default => 0, :null => false
    t.integer  "subscribed_users",                    :default => 0, :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "requested_invites", ["email"], :name => "UNIQUE_EMAIL", :unique => true
  add_index "requested_invites", ["invite_code"], :name => "UNIQUE_INVITE_CODE", :unique => true
  add_index "requested_invites", ["subscription_code"], :name => "UNIQUE_SUBSCRIPTION_CODE", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password"
    t.string   "auth"
    t.integer  "fb_user_id"
    t.integer  "twitter_id"
    t.string   "invite_code",                      :null => false
    t.integer  "requested_invites", :default => 0, :null => false
    t.integer  "subscribed_users",  :default => 0, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "users", ["auth"], :name => "UNIQUE_AUTH", :unique => true
  add_index "users", ["email"], :name => "UNIQUE_EMAIL", :unique => true
  add_index "users", ["fb_user_id"], :name => "UNIQUE_FB_USER_ID", :unique => true
  add_index "users", ["invite_code"], :name => "UNIQUE_INVITE_CODE", :unique => true
  add_index "users", ["twitter_id"], :name => "UNIQUE_TWITTER_ID", :unique => true

end
