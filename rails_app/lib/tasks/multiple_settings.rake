desc 'list texts which have multiple unrelated settings'
task multiple_settings: :environment do
  corpus_chants =
    Corpus
      .find_by_system_name('in_adiutorium')
      .chants

  replace = "regexp_replace(lyrics_normalized, ' aleluja$', '')"
  result =
    corpus_chants
      .group(:genre_id, replace)
      .select(:genre_id, replace + ' AS lyrics_further_normalized', 'COUNT(*) AS group_size')
      .having('COUNT(*) > 1')
      .order(:lyrics_further_normalized, :genre_id)

  result.each do |i|
    chants = corpus_chants.where(
      genre_id: i.genre_id,
      lyrics_normalized: i.lyrics_further_normalized&.yield_self {|x| [x, x + ' aleluja'] }
    )

    relatives = chants.first.relatives
    next if chants.all? {|c| relatives.include? c }

    puts "#{i.genre_id} #{i.group_size} #{i.lyrics_further_normalized} " +
         chants.collect {|j| "##{j.id}" }.join(' ')
  end
end
