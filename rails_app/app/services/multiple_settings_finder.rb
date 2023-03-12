# Finds chants which have the same lyrics, but are not related on the metadata level.
class MultipleSettingsFinder
  def call
    corpus_chants =
      Corpus
        .find_by_system_name('in_adiutorium')
        .chants

    replace = "regexp_replace(lyrics_normalized, ' aleluja$', '')"
    result =
      corpus_chants
        .group(replace)
        .select(replace + ' AS lyrics_further_normalized', 'COUNT(*) AS group_size')
        .having('COUNT(*) > 1')
        .order(:lyrics_further_normalized)

    result.reject do |i|
      chants = corpus_chants.where(
        lyrics_normalized: i.lyrics_further_normalized&.yield_self {|x| [x, x + ' aleluja'] }
      )
      relatives = chants.first.relatives

      chants.all? {|c| relatives.include? c }
    end
  end
end
