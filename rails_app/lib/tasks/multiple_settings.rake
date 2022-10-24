desc 'list texts which have multiple unrelated settings'
task multiple_settings: :environment do
  corpus_chants =
    Corpus
      .find_by_system_name('in_adiutorium')
      .chants

  result =
    corpus_chants
      .group(:genre_id, :lyrics_normalized)
      .select(:genre_id, :lyrics_normalized, 'COUNT(*) AS group_size')
      .having('COUNT(*) > 1')
      .order(:lyrics_normalized, :genre_id)

  result.each do |i|
    chants = corpus_chants.where(genre_id: i.genre_id, lyrics_normalized: i.lyrics_normalized)

    relatives = chants.first.relatives
    next if chants.all? {|c| relatives.include? c }

    puts "#{i.genre_id} #{i.group_size} #{i.lyrics_normalized} " +
         chants.collect {|j| "##{j.id}" }.join(' ')
  end
end
