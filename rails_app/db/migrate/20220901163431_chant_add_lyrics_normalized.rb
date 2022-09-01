class ChantAddLyricsNormalized < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :lyrics_normalized, :text
    add_index :chants, :lyrics_normalized
  end
end
