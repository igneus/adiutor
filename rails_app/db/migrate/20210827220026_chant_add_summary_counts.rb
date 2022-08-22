class ChantAddSummaryCounts < ActiveRecord::Migration[6.1]
  def change
    change_table :chants do |t|
      t.integer :syllable_count
      t.integer :word_count
      t.integer :melody_section_count
    end
  end
end
