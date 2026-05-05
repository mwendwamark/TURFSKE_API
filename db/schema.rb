# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_05_03_044144) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "amenities", force: :cascade do |t|
    t.bigint "turf_venue_id", null: false
    t.boolean "showers"
    t.boolean "toilets"
    t.boolean "floodlights"
    t.boolean "ball_provided"
    t.boolean "free_parking"
    t.boolean "drinking_water"
    t.boolean "bibs_vests"
    t.boolean "spectator_seating"
    t.boolean "canteen"
    t.boolean "referee"
    t.boolean "cctv"
    t.boolean "wifi"
    t.boolean "first_aid"
    t.boolean "changing_rooms"
    t.text "extra_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turf_venue_id"], name: "index_amenities_on_turf_venue_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "turf_id", null: false
    t.string "reference_number"
    t.date "slot_date"
    t.time "start_time"
    t.time "end_time"
    t.decimal "duration_hours"
    t.integer "amount_kes"
    t.string "status"
    t.text "cancel_reason"
    t.string "cancelled_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "player_id"
    t.index ["player_id"], name: "index_bookings_on_player_id"
    t.index ["turf_id"], name: "index_bookings_on_turf_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "turf_venue_id", null: false
    t.bigint "user_id", null: false
    t.string "payment_type"
    t.integer "amount_kobo"
    t.string "currency"
    t.string "paystack_reference"
    t.string "paystack_transaction_id"
    t.string "channel"
    t.string "status"
    t.jsonb "paystack_metadata"
    t.string "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turf_venue_id"], name: "index_payments_on_turf_venue_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "turf_id", null: false
    t.bigint "booking_id", null: false
    t.integer "rating"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "player_id"
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["player_id"], name: "index_reviews_on_player_id"
    t.index ["turf_id"], name: "index_reviews_on_turf_id"
  end

  create_table "turf_availabilities", force: :cascade do |t|
    t.bigint "turf_id", null: false
    t.integer "day_of_week"
    t.boolean "is_open"
    t.time "open_time"
    t.time "close_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turf_id"], name: "index_turf_availabilities_on_turf_id"
  end

  create_table "turf_venues", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "description"
    t.text "full_address"
    t.string "county"
    t.string "landmark"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "contact_phone"
    t.string "whatsapp_number"
    t.string "contact_email"
    t.string "paystack_reference"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_turf_venues_on_user_id"
  end

  create_table "turves", force: :cascade do |t|
    t.bigint "turf_venue_id", null: false
    t.string "name"
    t.string "surface_type"
    t.string "pitch_format"
    t.decimal "pitch_length_m"
    t.decimal "pitch_width_m"
    t.integer "price_per_hour"
    t.integer "peak_price"
    t.time "peak_from"
    t.time "peak_to"
    t.integer "min_booking_minutes"
    t.integer "slot_duration_minutes"
    t.integer "buffer_minutes"
    t.boolean "auto_approve"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["turf_venue_id"], name: "index_turves_on_turf_venue_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "roles", default: [], array: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "amenities", "turf_venues"
  add_foreign_key "bookings", "turves"
  add_foreign_key "bookings", "users", column: "player_id"
  add_foreign_key "payments", "turf_venues"
  add_foreign_key "payments", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "turves"
  add_foreign_key "reviews", "users", column: "player_id"
  add_foreign_key "turf_availabilities", "turves"
  add_foreign_key "turf_venues", "users"
  add_foreign_key "turves", "turf_venues"
end
