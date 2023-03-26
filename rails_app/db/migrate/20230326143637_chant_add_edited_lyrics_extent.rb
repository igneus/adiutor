class ChantAddEditedLyricsExtent < ActiveRecord::Migration[7.0]
  def change
    add_column :chants, :edited_lyrics_extent, :integer
  end
end
