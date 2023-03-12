# Finds chants which have the same lyrics, but are not related on the metadata level.
class MultipleSettingsFinder
  def call
    corpus_chants =
      Corpus
        .find_by_system_name('in_adiutorium')
        .chants

    strip_alleluia = -> (column) { "regexp_replace(#{column}, ' aleluja$', '') AS lyrics_further_normalized" }

    query1 = corpus_chants.select(:id, strip_alleluia.('lyrics_normalized'))
    query2 =
      corpus_chants
        .select(:id, strip_alleluia.('textus_approbatus_normalized'))
        .where.not(textus_approbatus_normalized: nil)
    sql = Chant.connection.unprepared_statement do
      "((#{query1.to_sql}) UNION (#{query2.to_sql})) AS items"
    end

    result =
      Chant.from(sql)
        .group('lyrics_further_normalized')
        .select('lyrics_further_normalized', 'COUNT(*) AS group_size')
        .having('COUNT(*) > 1')
        .order(:lyrics_further_normalized)

    result.reject do |i|
      with_or_without_alleluia = i.lyrics_further_normalized.yield_self {|x| [x, x + ' aleluja'] }
      chants =
        corpus_chants
          .where(lyrics_normalized: with_or_without_alleluia)
          .or(corpus_chants.where(textus_approbatus_normalized: with_or_without_alleluia))
      relatives = chants.first.relatives

      chants.all? {|c| relatives.include? c }
    end
  end
end
