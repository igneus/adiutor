class CreateMusicBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :music_books do |t|
      t.belongs_to :corpus, null: false
      t.string :title
      t.string :publisher
      t.integer :year

      t.timestamps
    end

    add_belongs_to :chants, :music_book
  end
end
