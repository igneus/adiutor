class AddMissingForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :chants, :books
    add_foreign_key :chants, :cycles
    add_foreign_key :chants, :seasons

    add_foreign_key :chants, :corpuses, column: :corpus_id
    add_foreign_key :chants, :source_languages
    add_foreign_key :chants, :genres
    add_foreign_key :chants, :hours
    add_foreign_key :chants, :music_books

    add_foreign_key :music_books, :corpuses, column: :corpus_id

    add_foreign_key :parent_child_mismatches, :chants, column: :child_id
  end
end
