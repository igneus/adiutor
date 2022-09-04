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

corpus_chants = Chant.where(
  corpus: Corpus.find_by_system_name('in_adiutorium'),
  book: Book.find_by_system_name('dmc')
)

t = Chant.arel_table

ARGF.each_with_index do |l, i|
  genre, lyrics, _ = CSV.parse_line l
  next if lyrics.nil? # TODO: this should not happen, investigate

  # 1. search by literal lyrics
  by_lyrics =
    if genre == 'Rb'
      corpus_chants.where('lyrics LIKE ?', lyrics.sub(' V. ', ' ') + ' * %')
    else
      corpus_chants.where(
        t[:lyrics].eq(lyrics)
          .or(t[:textus_approbatus].eq(lyrics))
          .or(t[:alleluia_optional].eq(true).and(t[:lyrics].eq(lyrics + ' Aleluja.')))
      )
    end
  next if by_lyrics.present? # success, don't produce output and continue

  # 2. search less sensitive to minor differences
  normalized = normalizer.normalize_czech(lyrics.sub(' V. ', ' | '))
  by_normalized_lyrics = corpus_chants.where(
    t[:lyrics_normalized].eq(normalized)
      .or(t[:alleluia_optional].eq(true).and(t[:lyrics_normalized].eq(normalized + ' aleluja')))
  )

  if genre == 'A' && by_normalized_lyrics.present?
    they =
      lyrics
        .sub!(/, aleluja.$/, '. Aleluja.') # alleluia format deviating from the Czech printed breviary very frequent at breviar.sk - ignore it for now
    us = by_normalized_lyrics.first.lyrics

    next if they == us
  end

  puts CSV.generate_line([genre, lyrics, by_normalized_lyrics&.first&.lyrics])
end
