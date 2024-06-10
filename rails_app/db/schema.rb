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

ActiveRecord::Schema[7.0].define(version: 2024_06_10_170549) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "books", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.bigint "corpus_id", null: false
    t.bigint "source_language_id"
    t.string "volpiano"
    t.bigint "genre_id"
    t.bigint "hour_id"
    t.string "pitch_series"
    t.string "interval_series"
    t.boolean "simple_copy", default: false, null: false
    t.text "lyrics_normalized"
    t.boolean "alleluia_optional"
    t.boolean "copy", default: false, null: false
    t.bigint "music_book_id"
    t.integer "gregobase_chant_id"
    t.bigint "import_id"
    t.text "textus_approbatus_normalized"
    t.integer "children_tree_size"
    t.integer "source_file_position"
    t.integer "edited_lyrics_extent"
    t.string "ambitus_min_note", limit: 1
    t.string "ambitus_max_note", limit: 1
    t.integer "ambitus_interval"
    t.integer "development_versions_count", default: 0, null: false
    t.index ["book_id"], name: "index_chants_on_book_id"
    t.index ["corpus_id"], name: "index_chants_on_corpus_id"
    t.index ["cycle_id"], name: "index_chants_on_cycle_id"
    t.index ["genre_id"], name: "index_chants_on_genre_id"
    t.index ["hour_id"], name: "index_chants_on_hour_id"
    t.index ["import_id"], name: "index_chants_on_import_id"
    t.index ["lyrics_normalized"], name: "index_chants_on_lyrics_normalized"
    t.index ["music_book_id"], name: "index_chants_on_music_book_id"
    t.index ["parent_id"], name: "index_chants_on_parent_id"
    t.index ["season_id"], name: "index_chants_on_season_id"
    t.index ["source_language_id"], name: "index_chants_on_source_language_id"
  end

  create_table "corpuses", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cycles", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hours", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "imports", force: :cascade do |t|
    t.bigint "corpus_id", null: false
    t.datetime "started_at", precision: nil, null: false
    t.datetime "finished_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corpus_id"], name: "index_imports_on_corpus_id"
  end

  create_table "music_books", force: :cascade do |t|
    t.bigint "corpus_id", null: false
    t.string "title"
    t.string "publisher"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["corpus_id"], name: "index_music_books_on_corpus_id"
  end

  create_table "parent_child_mismatches", force: :cascade do |t|
    t.bigint "child_id"
    t.datetime "resolved_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_parent_child_mismatches_on_child_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "source_languages", force: :cascade do |t|
    t.string "name"
    t.string "system_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chants", "books"
  add_foreign_key "chants", "chants", column: "parent_id"
  add_foreign_key "chants", "corpuses", column: "corpus_id"
  add_foreign_key "chants", "cycles"
  add_foreign_key "chants", "genres"
  add_foreign_key "chants", "hours"
  add_foreign_key "chants", "imports"
  add_foreign_key "chants", "music_books"
  add_foreign_key "chants", "seasons"
  add_foreign_key "chants", "source_languages"
  add_foreign_key "imports", "corpuses", column: "corpus_id"
  add_foreign_key "music_books", "corpuses", column: "corpus_id"
  add_foreign_key "parent_child_mismatches", "chants", column: "child_id"
end
