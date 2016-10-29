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

ActiveRecord::Schema.define(version: 20161027152719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string   "key"
    t.integer  "call_count", default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "artist_credits", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "comic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comic_id"], name: "index_artist_credits_on_comic_id", using: :btree
    t.index ["creator_id"], name: "index_artist_credits_on_creator_id", using: :btree
  end

  create_table "comics", force: :cascade do |t|
    t.string   "diamond_code"
    t.string   "title"
    t.integer  "issue_number"
    t.text     "preview"
    t.decimal  "suggested_price"
    t.string   "item_type"
    t.date     "shipping_date"
    t.integer  "publisher_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "cover_image"
    t.integer  "weekly_list_id"
    t.boolean  "is_variant"
    t.integer  "reprint_number",     limit: 2
    t.string   "cover_thumbnail"
    t.boolean  "no_cover_available"
    t.index ["diamond_code"], name: "index_comics_on_diamond_code", using: :btree
    t.index ["publisher_id"], name: "index_comics_on_publisher_id", using: :btree
    t.index ["shipping_date"], name: "index_comics_on_shipping_date", using: :btree
    t.index ["title"], name: "index_comics_on_title", using: :btree
    t.index ["weekly_list_id"], name: "index_comics_on_weekly_list_id", using: :btree
  end

  create_table "cover_artist_credits", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "comic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comic_id"], name: "index_cover_artist_credits_on_comic_id", using: :btree
    t.index ["creator_id"], name: "index_cover_artist_credits_on_creator_id", using: :btree
  end

# Could not dump table "creator_credits" because of following StandardError
#   Unknown type 'creator_type' for column 'credited_as'

  create_table "creators", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_creators_on_name", using: :btree
  end

  create_table "publishers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_publishers_on_name", using: :btree
  end

  create_table "weekly_lists", force: :cascade do |t|
    t.text     "list"
    t.date     "wednesday_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["wednesday_date"], name: "index_weekly_lists_on_wednesday_date", using: :btree
  end

  create_table "writer_credits", force: :cascade do |t|
    t.integer  "creator_id"
    t.integer  "comic_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comic_id"], name: "index_writer_credits_on_comic_id", using: :btree
    t.index ["creator_id"], name: "index_writer_credits_on_creator_id", using: :btree
  end

  add_foreign_key "artist_credits", "comics"
  add_foreign_key "artist_credits", "creators"
  add_foreign_key "comics", "publishers"
  add_foreign_key "comics", "weekly_lists"
  add_foreign_key "cover_artist_credits", "comics"
  add_foreign_key "cover_artist_credits", "creators"
  add_foreign_key "creator_credits", "comics"
end
