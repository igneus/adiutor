module LyricsHelper
  extend self

  # Normalizes "WHOle first syllable initial" (common in gabc transcriptions of chant books)
  # to "Single letter initial".
  def normalize_initial(lyrics)
    lyrics.sub(/^[[:upper:]]{2,}/, &:titlecase)
  end

  def remove_euouae(lyrics)
    lyrics.sub(/\s*e u o u a e\.?$/i, '')
  end
end
