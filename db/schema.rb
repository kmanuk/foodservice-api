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

ActiveRecord::Schema.define(version: 20170629105156) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "addresses", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "location"
    t.index ["latitude"], name: "index_addresses_on_latitude", using: :btree
    t.index ["longitude"], name: "index_addresses_on_longitude", using: :btree
  end

  create_table "admin_users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "cancellations", force: :cascade do |t|
    t.integer  "who"
    t.string   "reason"
    t.string   "status"
    t.integer  "user_id"
    t.integer  "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_cancellations_on_order_id", using: :btree
    t.index ["user_id"], name: "index_cancellations_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "en"
    t.string   "description"
    t.string   "ar"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "product_type_id"
    t.index ["product_type_id"], name: "index_categories_on_product_type_id", using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.string   "imageable_type"
    t.integer  "imageable_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
    t.index ["imageable_type", "imageable_id"], name: "index_images_on_imageable_type_and_imageable_id", using: :btree
  end

  create_table "items", force: :cascade do |t|
    t.integer  "sub_category_id"
    t.integer  "user_id"
    t.text     "information"
    t.float    "price",           default: 0.0
    t.integer  "amount",          default: 1
    t.float    "time_to_cook",    default: 0.0
    t.string   "type"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "name"
    t.integer  "product_type_id"
    t.integer  "category_id"
    t.float    "total_price"
    t.index ["category_id"], name: "index_items_on_category_id", using: :btree
    t.index ["product_type_id"], name: "index_items_on_product_type_id", using: :btree
    t.index ["sub_category_id"], name: "index_items_on_sub_category_id", using: :btree
    t.index ["type"], name: "index_items_on_type", using: :btree
    t.index ["user_id"], name: "index_items_on_user_id", using: :btree
  end

  create_table "jobs", force: :cascade do |t|
    t.string   "worker_id"
    t.string   "name"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "line_items", force: :cascade do |t|
    t.integer  "order_id"
    t.decimal  "price",        precision: 8, scale: 2
    t.integer  "quantity"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.decimal  "total_price",  precision: 8, scale: 2
    t.string   "name"
    t.integer  "item_id"
    t.float    "time_to_cook",                         default: 0.0
    t.string   "image_url"
    t.index ["order_id"], name: "index_line_items_on_order_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "buyer_id"
    t.integer  "seller_id"
    t.integer  "driver_id"
    t.integer  "status",           default: 0,     null: false
    t.datetime "confirmed_at"
    t.datetime "pickedup_at"
    t.datetime "delivered_at"
    t.integer  "delivery_type"
    t.integer  "payment_type"
    t.integer  "payment_id"
    t.float    "price"
    t.float    "delivery_price"
    t.float    "fee_price"
    t.integer  "address_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "type"
    t.integer  "distance",         default: 0
    t.integer  "duration",         default: 0
    t.text     "polyline",         default: ""
    t.jsonb    "delivery_steps",   default: {},    null: false
    t.integer  "cooking_time"
    t.datetime "estimation_ready"
    t.float    "service_fee"
    t.boolean  "paid",             default: false
    t.float    "total_price"
    t.float    "global_price"
    t.index ["address_id"], name: "index_orders_on_address_id", using: :btree
    t.index ["buyer_id"], name: "index_orders_on_buyer_id", using: :btree
    t.index ["driver_id"], name: "index_orders_on_driver_id", using: :btree
    t.index ["seller_id"], name: "index_orders_on_seller_id", using: :btree
  end

  create_table "payments", force: :cascade do |t|
    t.string   "token"
    t.string   "card_number"
    t.string   "expiry_date"
    t.string   "card_bin"
    t.string   "card_holder_name"
    t.string   "remember"
    t.integer  "order_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "merchant_reference"
    t.integer  "status",             default: 0
    t.string   "ip_address"
    t.index ["order_id"], name: "index_payments_on_order_id", using: :btree
  end

  create_table "product_types", force: :cascade do |t|
    t.string   "en"
    t.string   "ar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.float    "rate"
    t.string   "message"
    t.string   "ratable_type"
    t.integer  "ratable_id"
    t.integer  "reviewer_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "status"
    t.integer  "order_id"
    t.index ["order_id"], name: "index_reviews_on_order_id", using: :btree
    t.index ["ratable_type", "ratable_id"], name: "index_reviews_on_ratable_type_and_ratable_id", using: :btree
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id", using: :btree
  end

  create_table "sub_categories", force: :cascade do |t|
    t.string   "en"
    t.string   "description"
    t.string   "ar"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_sub_categories_on_category_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider",                    default: "email", null: false
    t.string   "uid",                         default: "",      null: false
    t.string   "encrypted_password",          default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "phone"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "token"
    t.integer  "role"
    t.integer  "address_id"
    t.boolean  "recommended_seller",          default: false
    t.boolean  "approved_driver",             default: false
    t.boolean  "certified_driver",            default: false
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.string   "locale"
    t.integer  "quickblox_user_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "name"
    t.boolean  "active",                      default: true
    t.string   "video_snapshot_file_name"
    t.string   "video_snapshot_content_type"
    t.integer  "video_snapshot_file_size"
    t.datetime "video_snapshot_updated_at"
    t.string   "business_name"
    t.boolean  "active_driver",               default: true
    t.string   "iban"
    t.string   "bank_name"
    t.string   "car_type"
    t.string   "plate_number"
    t.string   "driver_license"
    t.string   "insurance_name"
    t.string   "insurance_number"
    t.integer  "push_count_messages",         default: 0
    t.integer  "push_count_orders",           default: 0
    t.index ["address_id"], name: "index_users_on_address_id", using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["latitude"], name: "index_users_on_latitude", using: :btree
    t.index ["longitude"], name: "index_users_on_longitude", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role"], name: "index_users_on_role", using: :btree
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  end

  add_foreign_key "cancellations", "orders", on_delete: :cascade
  add_foreign_key "cancellations", "users", on_delete: :cascade
  add_foreign_key "categories", "product_types"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "product_types"
  add_foreign_key "items", "sub_categories"
  add_foreign_key "items", "users"
  add_foreign_key "line_items", "orders", on_delete: :cascade
  add_foreign_key "orders", "addresses", on_delete: :cascade
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "orders", "users", column: "driver_id"
  add_foreign_key "orders", "users", column: "seller_id"
  add_foreign_key "payments", "orders"
  add_foreign_key "reviews", "orders"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "sub_categories", "categories", on_delete: :cascade
  add_foreign_key "users", "addresses", on_delete: :cascade
end
