module LyricsHelper
  extend self

  # Normalizes "WHOle first syllable initial" (common in gabc transcriptions of chant books)
  # to "Single letter initial".
  def normalize_initial(lyrics)
    lyrics.sub(/^[[:upper:]]{2,}/, &:titlecase)
  end
end
