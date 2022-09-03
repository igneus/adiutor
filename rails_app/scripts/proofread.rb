# Usage:
#
#   rails runner scripts/proofread.rb file_with_chant_texts.csv
#
# Expects the CSV file to contain genre codes and chant texts,
# in the format produced by code of the "loth-chants-dataset" project.
# Attempts to find each chant text in the database, prints texts not found.
# (Thus proofreading the two datasets against each other.)

require 'csv'

normalizer = LyricsNormalizer.new

ARGF.each_with_index do |l, i|
  genre, lyrics, _ = CSV.parse_line l
  next if lyrics.nil? # TODO: this should not happen, investigate

  # 1. search by literal lyrics
  by_lyrics =
    if genre == 'Rb'
      Chant.where('lyrics LIKE ?', lyrics.sub(' V. ', ' ') + ' * %')
    else
      Chant.where(lyrics: lyrics)
    end
  next if by_lyrics.present? # success, don't produce output and continue

  # 2. search less sensitive to minor differences
  by_normalized_lyrics = Chant.where(lyrics_normalized: normalizer.normalize_czech(lyrics.sub('V.', '|')))

  puts CSV.generate_line([genre, lyrics, by_normalized_lyrics&.first&.lyrics])
end
