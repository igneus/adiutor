# How often do antiphons with the same initial words also share melody incipits?

require 'csv'

def common_beginning_length(a, b)
  0.upto([a.size, b.size].min).find do |i|
    a[i] != b[i]
  end
end

def volpiano_syllables(volp)
  volp.sub(/^1---/, '').split(/-{2,}/)
end



include Rails.application.routes.url_helpers

Chant
  .all_antiphons
  .where.not(corpus: Corpus.find_by_system_name('in_adiutorium'))
  .where.not(volpiano: nil)
  .where.not(lyrics_normalized: nil)
  .order(:corpus_id, :music_book_id, :lyrics_normalized)
  .each_cons(2) do |a, b|
  next if a.lyrics_normalized == b.lyrics_normalized

  lyrics_incipit = common_beginning_length a.lyrics_normalized.split, b.lyrics_normalized.split
  next if lyrics_incipit == 0

  music_incipit = common_beginning_length volpiano_syllables(a.volpiano), volpiano_syllables(b.volpiano)

  cols = [
    # the interesting results
    lyrics_incipit,
    music_incipit,

    # identification of both chants
    a.id,
    a.lyrics,
    b.id,
    b.lyrics,

    chants_url(
      ids: [a, b].collect {|i| i.id.to_s }.join(','),
      host: 'localhost:3000'
    )
  ]
  puts CSV.generate_line(cols)
end
