class CreateSourceLanguages < ActiveRecord::Migration[6.1]
  def change
    create_table :source_languages do |t|
      t.string :name
      t.string :system_name

      t.timestamps
    end

    change_table :chants do |t|
      t.belongs_to :source_language
      t.rename :lilypond_code, :source_code
    end
  end
end
