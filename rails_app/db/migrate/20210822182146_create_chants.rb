class CreateChants < ActiveRecord::Migration[6.1]
  def change
    create_table :chants do |t|
      t.text :lilypond_code
      t.text :lyrics
      t.json :header
      t.string :quid
      t.string :modus, limit: 8
      t.string :differentia, limit: 8
      t.string :psalmus
      t.string :chant_id
      t.text :source_file_path

      t.timestamps
    end
  end
end
