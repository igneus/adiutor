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

ActiveRecord::Schema.define(version: 2021_09_28_184209) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "chants", force: :cascade do |t|
    t.text "source_code"
    t.text "lyrics"
    t.json "header"
    t.string "quid"
    t.string "modus", limit: 8
    t.string "differentia", limit: 8
    t.string "psalmus"
    t.string "chant_id"
    t.text "source_file_path"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "placet"
    t.text "textus_approbatus"
    t.string "fial"
    t.bigint "parent_id"
    t.bigint "book_id"
    t.bigint "cycle_id"
    t.bigint "season_id"
    t.integer "syllable_count"
    t.integer "word_count"
    t.integer "melody_section_count"
    t.bigint "corpus_id"
    t.bigint "source_language_id"
    t.string "volpiano"
    t.bigint "genre_id"
    t.bigint "hour_id"
    t.string "pitch_series"
    t.string "interval_series"
    t.index ["book_id"], name: "index_chants_on_book_id"
    t.index ["corpus_id"], name: "index_chants_on_corpus_id"
    t.index ["cycle_id"], name: "index_chants_on_cycle_id"
    t.index ["genre_id"], name: "index_chants_on_genre_id"
    t.index ["hour_id"], name: "index_chants_on_hour_id"
    t.index ["parent_id"], name: "index_chants_on_parent_id"
    t.index ["season_id"], name: "index_chants_on_season_id"
    t.index ["source_language_id"], name: "index_chants_on_source_language_id"
  end

  create_table "corpuses", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cycles", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "hours", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "parent_child_mismatches", force: :cascade do |t|
    t.bigint "child_id"
    t.datetime "resolved_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["child_id"], name: "index_parent_child_mismatches_on_child_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "source_languages", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "chants", "chants", column: "parent_id"
end
