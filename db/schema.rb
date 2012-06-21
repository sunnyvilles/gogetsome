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

ActiveRecord::Schema.define(:version => 20120621163626) do

  create_table "associated_categories", :force => true do |t|
    t.integer  "parent_category_id",                       :null => false
    t.integer  "child_category_id",                        :null => false
    t.integer  "associated_products_count", :default => 0, :null => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "associated_categories", ["child_category_id"], :name => "index_associated_categories_on_child_category_id"
  add_index "associated_categories", ["parent_category_id", "child_category_id"], :name => "UNIQUE_CAT_ASSOC", :unique => true
  add_index "associated_categories", ["parent_category_id"], :name => "index_associated_categories_on_parent_category_id"

  create_table "categories", :force => true do |t|
    t.string   "name",                      :limit => 50,                :null => false
    t.integer  "associated_products_count",               :default => 0, :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name"

  create_table "countries", :force => true do |t|
    t.string   "name",       :limit => 50, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "product_categories", :force => true do |t|
    t.integer  "product_id",  :null => false
    t.integer  "category_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "product_categories", ["category_id"], :name => "index_product_categories_on_category_id"
  add_index "product_categories", ["product_id"], :name => "index_product_categories_on_product_id"

  create_table "product_views", :force => true do |t|
    t.integer  "product_id", :null => false
    t.string   "ip_address"
    t.integer  "site_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "products", :force => true do |t|
    t.string   "name",                 :limit => 200
    t.string   "url",                  :limit => 200,                    :null => false
    t.string   "primary_image_url",    :limit => 200
    t.string   "image_url_1",          :limit => 200
    t.string   "image_url_2",          :limit => 200
    t.string   "image_url_3",          :limit => 200
    t.string   "brand",                :limit => 200
    t.integer  "primary_image_width"
    t.integer  "primary_image_height"
    t.integer  "discount_price"
    t.integer  "actual_price"
    t.boolean  "status",                              :default => false, :null => false
    t.integer  "views"
    t.integer  "country_id"
    t.integer  "site_id"
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  add_index "products", ["url"], :name => "UNIQUE_URL", :unique => true

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

  create_table "sites", :force => true do |t|
    t.string   "name",       :limit => 50,                :null => false
    t.string   "site_url",   :limit => 50,                :null => false
    t.integer  "country_id",               :default => 1, :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

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
